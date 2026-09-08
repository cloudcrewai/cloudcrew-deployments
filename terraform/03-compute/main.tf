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

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

# KMS Key for CloudWatch Logs (RULE 22, RULE 17)
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

# KMS Alias for CloudWatch Logs (RULE 27, RULE 29)
resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# VPC Flow Logs Log Group (RULE 13, RULE 22, CloudWatch log group retention)
# IAM Role for VPC Flow Logs (RULE 13)
resource "aws_iam_role" "flow_logs" {
  name_prefix        = "production-vpc-rds-pro-flow-logs-role-" # RULE 26, RULE 58
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
    create_before_destroy = true
  }
}

# IAM Policy for VPC Flow Logs (RULE 13, RULE 13b)
resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-${var.environment}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/${var.project_name}/*"
      }
    ]
  })
}

# VPC Flow Log (RULE 13)
# S3 Bucket for CloudTrail Logs (RULE 38, RULE 31 override)
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "production-vpc-rds-p-cloudtrail-logs-" # RULE 58
  force_destroy = false # RULE 38
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# S3 Bucket Public Access Block for CloudTrail Logs (S3 rules)
resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Versioning for CloudTrail Logs (S3 rules)
resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Ownership Controls for CloudTrail Logs (S3 rules)
resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 Bucket Server Side Encryption for CloudTrail Logs (S3 rules)
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.terraform_remote_state.data.outputs.kms_s3_key_arn
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Lifecycle Configuration for CloudTrail Logs (RULE 23)
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Policy for CloudTrail Logs (RULE 20)
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

# CloudWatch Log Group for CloudTrail (RULE 38, CloudWatch log group retention)
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = data.terraform_remote_state.data.outputs.cloudtrail_log_group_name # Using remote state output
  retention_in_days = var.audit_log_retention_days                                        # RULE 38
  kms_key_id        = aws_kms_key.logs.arn                                                # RULE 22
  tags              = var.tags
}

# IAM Role for CloudTrail to deliver to CloudWatch Logs (RULE 38)
resource "aws_iam_role" "cloudtrail" {
  name_prefix        = "production-vpc-rds-pr-cloudtrail-role-" # RULE 26, RULE 58
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

# IAM Policy for CloudTrail to deliver to CloudWatch Logs (RULE 38, RULE 13b)
resource "aws_iam_role_policy" "cloudtrail" {
  name = "${var.project_name}-${var.environment}-cloudtrail-policy"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${data.terraform_remote_state.data.outputs.cloudtrail_log_group_name}:*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

# CloudTrail (RULE 38, RULE 59, CloudTrail KMS encryption, CloudTrail data events)
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true # RULE 38
  include_global_service_events = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  cloud_watch_logs_group_arn    = "${data.terraform_remote_state.data.outputs.cloudtrail_log_group_arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  kms_key_id                    = data.terraform_remote_state.data.outputs.kms_s3_key_arn # CloudTrail KMS encryption
  tags                          = var.tags

  event_selector { # CloudTrail data events
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*/*"]
    }
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"]
    }
  }
}

# CloudWatch Metric Filter for Root Account Usage (CloudWatch security metric filters)
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-${var.environment}-root-login-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.project_name}-${var.environment}-root-login-count"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Root Account Usage (CloudWatch alarms with SNS required for production)
resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "${var.project_name}-${var.environment}-root-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account is used for login"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

# CloudWatch Metric Filter for Console Sign-in Without MFA (CloudWatch security metric filters)
resource "aws_cloudwatch_log_metric_filter" "mfa_disabled_login" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-login-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.project_name}-${var.environment}-mfa-disabled-login-count"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Console Sign-in Without MFA (CloudWatch alarms with SNS required for production)
resource "aws_cloudwatch_metric_alarm" "mfa_disabled_login" {
  alarm_name          = "${var.project_name}-${var.environment}-mfa-disabled-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login occurs without MFA"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

# CloudWatch Metric Filter for Unauthorized API Calls (CloudWatch security metric filters)
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.project_name}-${var.environment}-unauthorized-api-calls-count"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# CloudWatch Alarm for Unauthorized API Calls (CloudWatch alarms with SNS required for production)
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-calls-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls are detected"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
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
