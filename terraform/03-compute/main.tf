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
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for S3 Data Lake Encryption (from blueprint component "kms_key")
resource "aws_kms_key" "s3_encryption" {
  description             = "CMK for ${var.project_name} S3 Data Lake encryption"
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
        Sid    = "AllowS3UseOfKey"
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

resource "random_id" "kms_s3_encryption_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3_encryption" {
  name          = "alias/${var.project_name}-${var.environment}-s3-encryption-${random_id.kms_s3_encryption_suffix.hex}"
  target_key_id = aws_kms_key.s3_encryption.key_id
}

# S3 Bucket Server-Side Encryption Configuration for the Data Lake
# The S3 bucket itself is created in phase 02-data, this configures its encryption.
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = data.terraform_remote_state.data.outputs.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
    bucket_key_enabled = true
  }
}

# CloudTrail Audit Logging (from blueprint component "cloudtrail")
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_arn}:*"
  cloud_watch_logs_role_arn     = data.terraform_remote_state.data.outputs.iam_cloudtrail_role_arn
  kms_key_id                    = data.terraform_remote_state.data.outputs.kms_cloudtrail_key_id
  tags                          = var.tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/", # Data Lake
        "${data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_arn}/", # CloudTrail logs
        "${data.terraform_remote_state.data.outputs.s3_config_bucket_arn}/", # Config logs
        "${data.terraform_remote_state.data.outputs.s3_access_logs_bucket_arn}/" # Access logs
      ]
    }
    data_resource {
      type = "AWS::Lambda::Function"
      values = [
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
      ]
    }
  }
}

# AWS Config Compliance (from blueprint component "aws_config")
resource "aws_iam_role" "config" {
  name_prefix = "hipaa-data-governance-pro-config-role-"
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
        Resource = "${data.terraform_remote_state.data.outputs.s3_config_bucket_arn}/AWSConfig/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Action   = "s3:GetBucketAcl"
        Effect   = "Allow"
        Resource = data.terraform_remote_state.data.outputs.s3_config_bucket_arn
      },
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = data.terraform_remote_state.data.outputs.sns_alarms_topic_arn
      },
      {
        Action   = "logs:PutLogEvents"
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.config_logs.arn}:*"
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name          = "${var.project_name}-${var.environment}-delivery-channel"
  s3_bucket_name = data.terraform_remote_state.data.outputs.s3_config_bucket_id
  sns_topic_arn = data.terraform_remote_state.data.outputs.sns_alarms_topic_arn
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_cloudwatch_log_group" "config_logs" {
  name              = "/aws/config/${var.project_name}/${var.environment}"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = data.terraform_remote_state.data.outputs.kms_logs_key_id
  tags              = var.tags
}

# AWS Config Managed Rules
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "${var.project_name}-${var.environment}-s3-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "${var.project_name}-${var.environment}-rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "${var.project_name}-${var.environment}-iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "${var.project_name}-${var.environment}-encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "${var.project_name}-${var.environment}-multi-region-cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
}

# GuardDuty Threat Detection (from blueprint component "guardduty")
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

resource "aws_cloudwatch_log_group" "guardduty_findings" {
  name              = "/aws/guardduty/${var.project_name}/${var.environment}/findings"
  retention_in_days = var.log_retention_days
  kms_key_id        = data.terraform_remote_state.data.outputs.kms_logs_key_id
  tags              = var.tags
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.project_name}-${var.environment}-guardduty-findings"
  description = "Route GuardDuty findings to SNS topic"
  event_pattern = jsonencode({
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"]
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "guardduty_findings" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToSNS"
  arn       = data.terraform_remote_state.data.outputs.sns_alarms_topic_arn
}

# Security Hub (from blueprint component "security_hub")
resource "aws_securityhub_account" "main" {
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# Amazon Transcribe (from blueprint component "transcribe")
resource "aws_iam_role" "transcribe" {
  name_prefix = "hipaa-data-governance-transcribe-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "transcribe.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "transcribe_s3_access" {
  name = "${var.project_name}-${var.environment}-transcribe-s3-access-policy"
  role = aws_iam_role.transcribe.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# CloudWatch Logs Metric Filters and Alarms (from blueprint component "cloudwatch_logs")
# Targeting the CloudTrail log group from phase 02-data

# Root Account Usage
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-${var.environment}-root-login-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

  metric_transformation {
    name          = "${var.project_name}-${var.environment}-RootLoginCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "${var.project_name}-${var.environment}-RootLoginAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account logs in"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

# Console Sign-in Without MFA
resource "aws_cloudwatch_log_metric_filter" "mfa_disabled_console_login" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-login-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

  metric_transformation {
    name          = "${var.project_name}-${var.environment}-MFADisabledLoginCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_disabled_console_login" {
  alarm_name          = "${var.project_name}-${var.environment}-MFADisabledLoginAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled_console_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled_console_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login without MFA occurs"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

# Unauthorized API Calls
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

  metric_transformation {
    name          = "${var.project_name}-${var.environment}-UnauthorizedAPICallCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-UnauthorizedAPICallsAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}
