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

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
}

# KMS Keys
resource "aws_kms_key" "rds" {
  description             = "${var.project_name}-${var.environment}-rds-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
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
        Sid    = "AllowRDSUse"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
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
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-data-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.rds.key_id
}

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
  name          = "alias/${var.project_name}-${var.environment}-data-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_kms_key" "s3" {
  description             = "${var.project_name}-${var.environment}-s3-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags

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
        Sid    = "AllowSNSEncryption"
        Effect = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action   = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource = "*"
      },
      {
        Sid    = "AllowS3Use"
        Effect = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
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
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-data-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.s3.key_id
}

# IAM Roles
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${var.project_name}-${var.environment}-rds-monitor-" # RULE 26, RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role" "cloudtrail" {
  name_prefix = "${var.project_name}-${var.environment}-ct-role-" # RULE 26, RULE 58
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
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "cloudtrail" {
  name = "${var.project_name}-${var.environment}-cloudtrail-policy"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
      {
        Action   = "s3:GetBucketAcl"
        Effect   = "Allow"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Action   = "s3:PutObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "backup" {
  name_prefix = "${var.project_name}-${var.environment}-backup-role-" # RULE 26, RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.s3.arn # Using S3 KMS key for SNS, as it's a general purpose key
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

# S3 Buckets
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-ct-logs-" # RULE 58
  force_destroy = false
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
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
        Resource = aws_s3_bucket.cloudtrail_logs.arn
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
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "backup_vault_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-backup-logs-" # RULE 58
  force_destroy = false
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "backup_vault_logs" {
  bucket                  = aws_s3_bucket.backup_vault_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backup_vault_logs" {
  bucket = aws_s3_bucket.backup_vault_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "backup_vault_logs" {
  bucket = aws_s3_bucket.backup_vault_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup_vault_logs" {
  bucket = aws_s3_bucket.backup_vault_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE 38
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  tags                          = var.tags

  event_selector { # Added for S3 and Lambda data events
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::"] # All S3 buckets
    }
    data_resource {
      type = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:::function:*"] # All Lambda functions
    }
  }
}

# AWS Backup
resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.s3.arn # Using S3 KMS key for Backup Vault
  tags        = var.tags

  # Optional: Configure access logging for the backup vault
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup-plan"
  tags = var.tags

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)" # Daily at 05:00 UTC

    lifecycle {
      delete_after = 35 # Retain backups for 35 days
    }
  }
}

resource "aws_backup_selection" "rds" {
  name          = "${var.project_name}-${var.environment}-rds-selection"
  plan_id       = aws_backup_plan.main.id
  iam_role_arn  = aws_iam_role.backup.arn
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}

# RDS Resources
resource "aws_rds_cluster_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-pg-cluster-" # RULE 26, RULE 58
  family      = "aurora-postgresql15"
  description = "RDS cluster parameter group for PostgreSQL 15"
  tags        = var.tags

  parameter {
    name  = "log_statement"
    value = "all" # Enable query logging for PostgreSQL
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${var.project_name}-${var.environment}-cluster"
  engine                          = "aurora-postgresql" # Use aurora-postgresql for cluster
  engine_version                  = "15.5"
  database_name                   = var.db_name
  master_username                 = var.db_username
  manage_master_user_password     = true # RULE 60
  master_user_secret_kms_key_id   = aws_kms_key.rds.arn # RULE 60
  db_subnet_group_name            = data.terraform_remote_state.networking.outputs.db_subnet_group_name
  vpc_security_group_ids          = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds.arn
  deletion_protection             = true # RULE 16
  backup_retention_period         = 30 # RULE 41
  preferred_backup_window         = "02:00-03:00"
  skip_final_snapshot             = false # RULE 16
  # Tag the cluster for AWS Backup selection
  tags = merge(var.tags, { Backup = "true" }) # Fixed: Removed duplicate tags = var.tags
}

resource "aws_rds_cluster_instance" "primary" {
  cluster_identifier              = aws_rds_cluster.main.id
  identifier                      = "${var.project_name}-${var.environment}-primary" # RULE 55
  instance_class                  = var.db_instance_class
  engine                          = aws_rds_cluster.main.engine
  engine_version                  = aws_rds_cluster.main.engine_version
  availability_zone               = data.aws_availability_zones.available.names[0]
  monitoring_interval             = 60 # RULE 50
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled    = local.enable_performance_insights # RULE 14b
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null # RULE 14b
  tags                            = var.tags
}

resource "aws_rds_cluster_instance" "replica_az_b" {
  cluster_identifier              = aws_rds_cluster.main.id
  identifier                      = "${var.project_name}-${var.environment}-replica-az-b" # RULE 55
  instance_class                  = var.db_instance_class
  engine                          = aws_rds_cluster.main.engine
  engine_version                  = aws_rds_cluster.main.engine_version
  availability_zone               = data.aws_availability_zones.available.names[1]
  monitoring_interval             = 60 # RULE 50
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled    = local.enable_performance_insights # RULE 14b
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null # RULE 14b
  tags                            = var.tags
}

resource "aws_rds_cluster_instance" "replica_az_c" {
  cluster_identifier              = aws_rds_cluster.main.id
  identifier                      = "${var.project_name}-${var.environment}-replica-az-c" # RULE 55
  instance_class                  = var.db_instance_class
  engine                          = aws_rds_cluster.main.engine
  engine_version                  = aws_rds_cluster.main.engine_version
  availability_zone               = data.aws_availability_zones.available.names[2]
  monitoring_interval             = 60 # RULE 50
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled    = local.enable_performance_insights # RULE 14b
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null # RULE 14b
  tags                            = var.tags
}

# Security Group Rules for existing DB Security Group
resource "aws_security_group_rule" "db_ingress_app" {
  type                     = "ingress"
  from_port                = 5432 # PostgreSQL default port
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.db_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow PostgreSQL access from application security group" # RULE 51
}

resource "aws_security_group_rule" "db_egress_vpc" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = data.terraform_remote_state.networking.outputs.db_security_group_id
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  description       = "Allow all outbound traffic within VPC" # RULE 51, RULE 8
}

# VPC Endpoints
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG can access Secrets Manager
  tags              = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG can access KMS
  tags              = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG can access CloudWatch Logs
  tags              = var.tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

# CloudWatch Metric Filters and Alarms
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "${var.project_name}-${var.environment}-root-usage-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "${var.project_name}-RootAccountUsage"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name          = "${var.project_name}-${var.environment}-root-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_usage.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_usage.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account is used"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mfa_disabled" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "${var.project_name}-ConsoleLoginWithoutMFA"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_disabled" {
  alarm_name          = "${var.project_name}-${var.environment}-mfa-disabled-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login without MFA occurs"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "${var.project_name}-UnauthorizedAPICalls"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU Utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-free-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10000000000 # 10 GB in bytes
  alarm_description   = "RDS Free Storage Space is less than 10 GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
  tags = var.tags
}

resource "aws_s3_bucket" "cloudtrail_logs_access" {
  bucket_prefix = "production-vpc-rds-pr-ct-access-logs-" # RULE 58
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_access" {
  bucket                  = aws_s3_bucket.cloudtrail_logs_access.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  versioning_configuration {
    status = "Enabled" # Access logs should be versioned
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn # Using S3 KMS key for access logs
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_logs_access" {
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "backup_vault_logs_logging" {
  bucket        = aws_s3_bucket.backup_vault_logs.id
  target_bucket = aws_s3_bucket.backup_vault_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_versioning" "cloudtrail_logs_access_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_logging" "cloudtrail_logs_access_logging" {
  bucket        = aws_s3_bucket.cloudtrail_logs_access.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}
