terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" { state = "available" }

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for S3 encryption and SageMaker (from blueprint)
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} SageMaker and S3"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowSageMakerService"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowECRService"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-sagemaker-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS Key for CloudWatch Logs (RULE 22)
resource "aws_kms_key" "logs" {
  description             = "${var.project_name}-${var.environment}-logs-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}" # RULE 27
  target_key_id = aws_kms_key.logs.key_id
}

# ECR Container Repository (from blueprint)
resource "aws_ecr_repository" "sagemaker_images" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "IMMUTABLE" # RULE 47

  image_scanning_configuration {
    scan_on_push = true # RULE 47
  }
  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "sagemaker_images" {
  repository = aws_ecr_repository.sagemaker_images.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remove untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}

# IAM Role for SageMaker (training, inference, monitoring)
resource "aws_iam_role" "sagemaker" {
  name_prefix        = "sagemaker-ml-platform-sagemaker-role-" # RULE 26, RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy" "sagemaker_s3_access" {
  name = "${var.project_name}-${var.environment}-sagemaker-s3-access"
  role = aws_iam_role.sagemaker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_training_data_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_training_data_bucket_arn}/*",
          data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_ecr_access" {
  name = "${var.project_name}-${var.environment}-sagemaker-ecr-access"
  role = aws_iam_role.sagemaker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = aws_ecr_repository.sagemaker_images.arn
      },
      {
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*" # ECR GetAuthorizationToken does not support resource-level permissions
      }
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_kms_access" {
  name = "${var.project_name}-${var.environment}-sagemaker-kms-access"
  role = aws_iam_role.sagemaker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_cloudwatch_access" {
  name = "${var.project_name}-${var.environment}-sagemaker-cloudwatch-access"
  role = aws_iam_role.sagemaker.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.sagemaker.name}:*"
        ]
      }
    ]
  })
}

# SageMaker Model Package Group (Required Core Model Registry)
resource "aws_sagemaker_model_package_group" "main" {
  model_package_group_name        = "${var.project_name}-${var.environment}-model-group"
  model_package_group_description = "Model package group for ${var.project_name} in ${var.environment}"
  tags                            = var.tags
}

# Security Group for SageMaker Training/Inference/Monitoring VPC access
resource "aws_security_group" "sagemaker_vpc_access" {
  name        = "${var.project_name}-${var.environment}-sagemaker-vpc-access-sg"
  description = "Security group for SageMaker training, inference, and monitoring VPC access"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags

  ingress {
    description = "Allow all traffic from within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  }

  egress {
    description = "All traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block] # RULE 8
  }
}

# SageMaker Model (representing the output of ml_training_job)
resource "aws_sagemaker_model" "main" {
  name                     = "${var.project_name}-${var.environment}-model"
  execution_role_arn       = aws_iam_role.sagemaker.arn # RULE 55
  enable_network_isolation = true                       # Best practice for security

  primary_container {
    image          = "${aws_ecr_repository.sagemaker_images.repository_url}:latest"
    model_data_url = "s3://${data.terraform_remote_state.data.outputs.s3_model_artifacts_bucket_id}/model.tar.gz" # Placeholder
  }

  vpc_config { # SageMaker VPC configuration rule
    security_group_ids = [aws_security_group.sagemaker_vpc_access.id]
    subnets            = data.terraform_remote_state.networking.outputs.private_subnet_ids
  }
  tags = var.tags
}

# SageMaker Endpoint Configuration (for ml_inference_endpoint)
resource "aws_sagemaker_endpoint_configuration" "main" {
  name        = "${var.project_name}-${var.environment}-endpoint-config"
  kms_key_arn = aws_kms_key.main.arn # RULE: SageMaker KMS argument names
  tags        = var.tags

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.main.name
    initial_instance_count = var.inference_initial_instance_count
    instance_type          = var.inference_instance_type
    initial_variant_weight = 1.0
  }

  data_capture_config {
    destination_s3_uri          = "s3://${data.terraform_remote_state.data.outputs.s3_access_logs_bucket_id}/sagemaker-data-capture/"
    enable_capture              = true
    initial_sampling_percentage = 100
    kms_key_id                  = aws_kms_key.main.arn
    capture_options {
      capture_mode = "Output"
    }
    capture_options {
      capture_mode = "Input"
    }
  }
}

# SageMaker Endpoint (for ml_inference_endpoint)
resource "aws_sagemaker_endpoint" "main" {
  name                 = "${var.project_name}-${var.environment}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
  tags                 = var.tags
}

# SageMaker Monitoring Schedule (RULE: SageMaker monitoring schedule required resources)
resource "aws_sagemaker_monitoring_schedule" "main" {
  name = "${var.project_name}-${var.environment}-data-quality-schedule"
  tags = var.tags

  monitoring_schedule_config {
    monitoring_type = "DataQuality"
    schedule_config {
      schedule_expression = "cron(0 * ? * * *)" # Hourly schedule
    }
    monitoring_job_definition {
      role_arn = aws_iam_role.sagemaker.arn
      monitoring_app_specification {
        image_uri = var.sagemaker_monitoring_image_uri # Placeholder for monitoring image
      }
      monitoring_inputs {
        endpoint_input {
          endpoint_name = aws_sagemaker_endpoint.main.name
          local_path    = "/opt/ml/processing/input"
        }
      }
      monitoring_output_config {
        kms_key_id = aws_kms_key.main.arn # optional, belongs HERE not on s3_output
        monitoring_outputs {
          s3_output {
            s3_uri     = "s3://${data.terraform_remote_state.data.outputs.s3_access_logs_bucket_id}/sagemaker-monitoring-output/"
            local_path = "/opt/ml/processing/output"
          }
        }
      }
      monitoring_resources {
        cluster_config {
          instance_count    = 1
          instance_type     = var.sagemaker_monitoring_instance_type
          volume_size_in_gb = 20
          volume_kms_key_id = aws_kms_key.main.arn # optional
        }
      }
      network_config {
        vpc_config {
          security_group_ids = [aws_security_group.sagemaker_vpc_access.id]
          subnets            = data.terraform_remote_state.networking.outputs.private_subnet_ids
        }
      }
    }
  }
}

# CloudWatch Log Group for SageMaker (from blueprint)
resource "aws_cloudwatch_log_group" "sagemaker" {
  name              = var.sagemaker_log_group_name
  retention_in_days = var.log_retention_days # RULE: CloudWatch log group retention
  kms_key_id        = aws_kms_key.logs.arn   # RULE: CloudWatch KMS encryption, RULE 22
  tags              = var.tags
}

# VPC Endpoints (RULE 43)
# Security Group for VPC Endpoints
resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags

  # Ingress from private subnets for all services
  ingress {
    description = "Allow all traffic from private subnets"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = data.terraform_remote_state.networking.outputs.private_subnet_ids
  }

  egress {
    description = "All traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block] # RULE 8
  }
}

# SageMaker API VPC Endpoint
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.sagemaker.api"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# SageMaker Runtime VPC Endpoint
resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.sagemaker.runtime"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# ECR Docker VPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# KMS VPC Endpoint
resource "aws_vpc_endpoint" "kms" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]
  tags               = var.tags
}

# S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

# GuardDuty (RULE 32)
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = var.tags
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.main.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

# Security Hub (RULE 33)
resource "aws_securityhub_account" "main" {
}

resource "aws_securityhub_standards_subscription" "foundational_security_best_practices" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# AWS Config (RULE 34)
resource "aws_iam_role" "config" {
  name_prefix        = "sagemaker-ml-platform-pro-config-role-" # RULE 26, RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy" "config_s3_access" {
  name = "${var.project_name}-${var.environment}-config-s3-access"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetBucketAcl"
        Resource = data.terraform_remote_state.data.outputs.s3_access_logs_bucket_arn
      },
      {
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "${data.terraform_remote_state.data.outputs.s3_access_logs_bucket_arn}/AWSConfig/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "config_sns_access" {
  name = "${var.project_name}-${var.environment}-config-sns-access"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.config_notifications.arn
    }]
  })
}

resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config.arn
  recording_group {
    all_supported              = true
    include_global_resource_types = true
  }
}

resource "aws_sns_topic" "config_notifications" {
  name              = "${var.project_name}-${var.environment}-config-notifications"
  kms_master_key_id = aws_kms_key.main.arn # RULE 45
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowConfigPublish"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config_notifications.arn
    }]
  })
}

resource "aws_config_delivery_channel" "main" {
  name          = "default"
  s3_bucket_name = data.terraform_remote_state.data.outputs.s3_access_logs_bucket_id
  sns_topic_arn = aws_sns_topic.config_notifications.arn
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

# AWS Config Managed Rules
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "multi-region-cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
}

# CloudWatch Alarms (RULE 35)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.main.arn # RULE 45
  tags              = var.tags
}

resource "aws_sns_topic_policy" "alarms" {
  arn = aws_sns_topic.alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudWatchAlarms"
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.alarms.arn
    }]
  })
}

resource "aws_cloudwatch_metric_alarm" "sagemaker_endpoint_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-sagemaker-endpoint-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  statistic           = "Average"
  threshold           = 80 # > 80% CPU
  namespace           = "AWS/SageMaker"
  metric_name         = "CPUUtilization"
  dimensions = {
    EndpointName = aws_sagemaker_endpoint.main.name
  }
  alarm_description = "SageMaker Endpoint CPU utilization is too high"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "sagemaker_endpoint_model_latency" {
  alarm_name          = "${var.project_name}-${var.environment}-sagemaker-endpoint-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  statistic           = "Average"
  threshold           = 5000 # > 5 seconds latency
  namespace           = "AWS/SageMaker"
  metric_name         = "ModelLatency"
  dimensions = {
    EndpointName = aws_sagemaker_endpoint.main.name
  }
  alarm_description = "SageMaker Endpoint Model Latency is too high"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
  tags              = var.tags
}

# CloudTrail (RULE 38)
resource "aws_iam_role" "cloudtrail" {
  name_prefix        = "sagemaker-ml-platform-cloudtrail-role-" # RULE 26, RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "${var.project_name}-${var.environment}-cloudtrail-logs-policy"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
      },
      {
        Action   = "logs:DescribeLogGroups"
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE: CloudWatch log group retention (audit tier)
  kms_key_id        = aws_kms_key.logs.arn         # RULE: CloudWatch KMS encryption, RULE 22
  tags              = var.tags
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = data.terraform_remote_state.data.outputs.s3_access_logs_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailLogging"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = data.terraform_remote_state.data.outputs.s3_access_logs_bucket_arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${data.terraform_remote_state.data.outputs.s3_access_logs_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = data.terraform_remote_state.data.outputs.s3_access_logs_bucket_id
  is_multi_region_trail         = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  include_global_service_events = true # RULE 38
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  tags                          = var.tags
}

# CloudWatch Security Metric Filters (RULE: CloudWatch security metric filters)
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-${var.environment}-root-login-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "RootLoginCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-root-login-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RootLoginCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when root account logs in"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mfa_disabled_console_login" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-console-login-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "MfaDisabledConsoleLoginCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_disabled_console_login_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-mfa-disabled-console-login-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MfaDisabledConsoleLoginCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when console login without MFA occurs"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "UnauthorizedApiCallsCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-calls-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedApiCallsCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}
