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
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "random_id" "kms_aurora_secrets_suffix" {
  byte_length = 4
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

# KMS Key for Aurora/Secrets
resource "aws_kms_key" "aurora_secrets" {
  description             = "${var.project_name}-${var.environment}-aurora-secrets-cmk"
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
        Sid    = "AllowSecretsManager"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
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

resource "aws_kms_alias" "aurora_secrets" {
  name          = "alias/${var.project_name}-${var.environment}-aurora-secrets-${random_id.kms_aurora_secrets_suffix.hex}"
  target_key_id = aws_kms_key.aurora_secrets.key_id
}

# KMS Key for CloudWatch Logs
resource "aws_kms_key" "cloudwatch_logs" {
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

resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

# DB Credentials Secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-"
  kms_key_id              = aws_kms_key.aurora_secrets.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy" {
  name_prefix = "aurora-postgresql-cluster-p-rds-proxy-"
  description = "Allows RDS Proxy to access Secrets Manager"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "rds_proxy_secrets_manager" {
  role       = aws_iam_role.rds_proxy.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# CloudWatch Log Group for Aurora
resource "aws_cloudwatch_log_group" "aurora" {
  name              = "/aws/rds/cluster/${data.terraform_remote_state.data.outputs.rds_cluster_id}/postgresql"
  retention_in_days = 365
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = 365
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for CloudTrail Logs
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = 365
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# IAM Role for CloudTrail to deliver logs to CloudWatch
resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  name_prefix = "aurora-postgresql-cloudtrail-cw-logs-"
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

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_logs" {
  name = "${var.project_name}-${var.environment}-cloudtrail-cw-logs-policy"
  role = aws_iam_role.cloudtrail_cloudwatch_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
      {
        Action   = ["logs:DescribeLogGroups"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudtrail/${var.project_name}-${var.environment}:*"
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = data.terraform_remote_state.data.outputs.s3_logs_bucket_name
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  kms_key_id                    = data.terraform_remote_state.data.outputs.kms_s3_key_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_logs.arn
  tags                          = var.tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::"] # All S3 buckets
    }
    data_resource {
      type = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"] # All Lambda functions
    }
  }
}

# S3 Bucket Policy for CloudTrail logs (RULE 20)
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = data.terraform_remote_state.data.outputs.s3_logs_bucket_name
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
        Resource = data.terraform_remote_state.data.outputs.s3_logs_bucket_arn
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
        Resource = "${data.terraform_remote_state.data.outputs.s3_logs_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
