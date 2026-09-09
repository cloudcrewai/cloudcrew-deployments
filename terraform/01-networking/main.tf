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
  az_list = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

#
# Networking
#
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_subnet" "private" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_subnet" "database" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false # RULE 12
  tags                    = var.tags
}

resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = var.tags
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route" "private_nat" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id # default route to the internet via NAT
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

# No internet route for database subnets
resource "aws_route_table_association" "database" {
  count          = var.az_count
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

#
# Security Groups
#
resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags

  ingress {
    description = "Allow all traffic from within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr] # RULE 8, Pattern A
  }
}

resource "aws_security_group" "public" {
  name        = "${var.project_name}-${var.environment}-public-sg"
  description = "Security group for public-facing resources (e.g., ALB)"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags

  # No public ingress from 0.0.0.0/0 on this SG, as ALB is not in this phase.
  # If ALB were here, it would allow 80/443 from 0.0.0.0/0.

  egress {
    description = "Allow all traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr] # RULE 8, Pattern A
  }
}

resource "aws_security_group" "private" {
  name        = "${var.project_name}-${var.environment}-private-sg"
  description = "Security group for private compute resources"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags

  ingress {
    description     = "Allow all traffic from public SG"
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    description = "Allow all traffic from within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr] # RULE 8, Pattern A
  }

  egress {
    description     = "Allow all traffic to VPC Endpoints"
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.vpce.id]
  }
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Security group for database resources"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags

  ingress {
    description     = "Allow PostgreSQL from private compute"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.private.id]
  }

  egress {
    description = "Allow all traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr] # RULE 8, Pattern A
  }
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-subnet-group-" # RULE 26
  subnet_ids  = aws_subnet.database[*].id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#
# VPC Endpoints
#
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.sagemaker.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.sagemaker.runtime"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.public[*].id, aws_route_table.private[*].id)
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce.id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpce.id]
  tags              = var.tags
}

#
# VPC Flow Logs (RULE 13)
#
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn # Encrypt flow logs with CMK
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  name_prefix = "${var.project_name}-flow-logs-role-" # RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*" # RULE 13b
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*" # RULE 13b
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn # RULE 59: NO ":*" here
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL" # RULE 13
  vpc_id               = aws_vpc.main.id
  tags                 = var.tags
}

#
# KMS Key for CloudWatch Logs (RULE 22, RULE 29)
#
resource "aws_kms_key" "logs" {
  description             = "${var.project_name}-${var.environment}-logs-cmk"
  deletion_window_in_days = 30 # RULE 17
  enable_key_rotation     = true # RULE 17
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
  name          = "alias/${var.project_name}-${var.environment}-networking-logs-${random_id.kms_logs_suffix.hex}" # RULE 27, RULE 29
  target_key_id = aws_kms_key.logs.key_id
}

#
# CloudTrail (RULE 38)
#
resource "aws_kms_key" "cloudtrail" {
  description             = "${var.project_name}-${var.environment}-cloudtrail-cmk"
  deletion_window_in_days = 30 # RULE 17
  enable_key_rotation     = true # RULE 17
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
        Sid    = "AllowCloudTrailUse"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
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

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-${var.environment}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # RULE 38
  tags          = var.tags
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
      kms_master_key_id = aws_kms_key.cloudtrail.arn
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

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE 38
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_iam_role" "cloudtrail" {
  name_prefix = "sagemaker-ml-platform-cloudtrail-role-" # RULE 26, RULE 58
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
        Action   = "logs:DescribeLogGroups"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  include_global_service_events = true # RULE 38
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  tags                          = var.tags
}

#
# GuardDuty (RULE 32)
#
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

#
# Security Hub (RULE 33)
#
resource "aws_securityhub_account" "main" {
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

#
# AWS Config (RULE 34)
#
resource "aws_s3_bucket" "config_bucket" {
  bucket        = "${var.project_name}-${var.environment}-config-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cloudtrail.arn # Reusing CloudTrail KMS for Config S3
    }
    bucket_key_enabled = true
  }
}

resource "aws_iam_role" "config" {
  name_prefix = "sagemaker-ml-platform-pro-config-role-" # RULE 26, RULE 58
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
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "config" {
  name = "${var.project_name}-${var.environment}-config-policy"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:PutObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.config_bucket.arn}/*"
        Condition = {
          StringLike = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Action   = "s3:GetBucketAcl"
        Effect   = "Allow"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alarms.arn # Using the alarms SNS topic for Config notifications
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  sns_topic_arn  = aws_sns_topic.alarms.arn # Using the alarms SNS topic for Config notifications
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [
    aws_config_configuration_recorder.main,
    aws_config_delivery_channel.main,
  ]
}

resource "aws_config_config_rule" "s3_public_read_prohibited" {
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

#
# CloudWatch Alarms and SNS Topic (RULE 45)
#
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.logs.arn # Using logs KMS key for SNS encryption
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

#
# CloudWatch Security Metric Filters and Alarms
#
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
  alarm_name          = "${var.project_name}-${var.environment}-RootAccountUsageAlarm"
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
  alarm_name          = "${var.project_name}-${var.environment}-ConsoleLoginWithoutMFAAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login occurs without MFA"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
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

resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "${var.project_name}-${var.environment}-UnauthorizedAPICallsAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_s3_bucket" "cloudtrail_logs_access" {
  bucket_prefix = "ct-access-logs-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_access" {
  bucket                  = aws_s3_bucket.cloudtrail_logs_access.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "cloudtrail_logs_access" {
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "config_bucket_logging" {
  bucket        = aws_s3_bucket.config_bucket.id
  target_bucket = aws_s3_bucket.config_bucket.id
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
