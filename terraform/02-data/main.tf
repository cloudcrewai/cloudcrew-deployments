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
  # RULE 14b: Performance Insights is not applicable to S3, but this local is
  # often generated for data phases. Keeping it for consistency if other DBs
  # were present.
  enable_performance_insights = false
}

# KMS Keys and Aliases (HIPAA encryption at rest)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-general-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRootAccount"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowSNSEncryption"
        Effect = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action   = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource = "*"
      }
    ]
  })
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-main-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
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
  name          = "alias/${var.project_name}-${var.environment}-data-logs-${random_id.kms_logs_suffix.hex}" # RULE 27, RULE 29
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
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "s3_access_logs" {
  description             = "${var.project_name}-${var.environment}-s3-access-logs-cmk"
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
        Sid    = "AllowS3AccessLogsUseOfKey"
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
}

resource "random_id" "kms_s3_access_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3_access_logs" {
  name          = "alias/${var.project_name}-${var.environment}-s3-access-logs-${random_id.kms_s3_access_logs_suffix.hex}"
  target_key_id = aws_kms_key.s3_access_logs.key_id
}

resource "aws_kms_key" "cloudtrail" {
  description             = "${var.project_name}-${var.environment}-cloudtrail-cmk"
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
        Sid    = "AllowCloudTrailUseOfKey"
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
}

resource "random_id" "kms_cloudtrail_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-${var.environment}-cloudtrail-${random_id.kms_cloudtrail_suffix.hex}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

resource "aws_kms_key" "config" {
  description             = "${var.project_name}-${var.environment}-config-cmk"
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
        Sid    = "AllowConfigUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
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

resource "random_id" "kms_config_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "config" {
  name          = "alias/${var.project_name}-${var.environment}-config-${random_id.kms_config_suffix.hex}"
  target_key_id = aws_kms_key.config.key_id
}

resource "aws_kms_key" "backup" {
  description             = "${var.project_name}-${var.environment}-backup-cmk"
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
        Sid    = "AllowBackupUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
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

resource "random_id" "kms_backup_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-${var.environment}-backup-${random_id.kms_backup_suffix.hex}"
  target_key_id = aws_kms_key.backup.key_id
}

# IAM Roles and Policies
resource "aws_iam_role" "flow_logs" {
  name_prefix = "hipaa-data-governance-flow-logs-role-" # RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "vpc-flow-logs.amazonaws.com" } }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-${var.environment}-flow-logs-policy" # RULE 58
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

resource "aws_iam_role" "cloudtrail" {
  name_prefix = "${var.project_name}-${var.environment}-ct-role-" # RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "cloudtrail.amazonaws.com" } }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "${var.project_name}-${var.environment}-cloudtrail-logs-policy" # RULE 58
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
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "config" {
  name_prefix = "hipaa-data-governance-pro-config-role-" # RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "config.amazonaws.com" } }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "config_delivery" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role" "backup" {
  name_prefix = "hipaa-data-governance-pro-backup-role-" # RULE 58
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "backup.amazonaws.com" } }]
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

# S3 Buckets and Companion Resources
resource "aws_s3_bucket" "data_lake" {
  bucket_prefix = "${var.project_name}-${var.environment}-data-lake-" # RULE 58
  force_destroy = false # RULE 30
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled" # RULE 30
  }
}

resource "aws_s3_bucket_ownership_controls" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
    filter {}
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    # RULE 23: expiration.days must be greater than every transition.days
    expiration {
      days = 3650 # 10 years
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
  rule {
    filter {}

    id     = "non-current-version-expiration"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket" "s3_access_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-s3-access-" # RULE 58
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_access_logs.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access_logs" {
  bucket                  = aws_s3_bucket.s3_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  versioning_configuration {
    status = "Suspended" # Log buckets typically don't need versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "S3BucketLoggingPolicy"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
      Condition = {
        ArnLike = {
          "aws:SourceArn" = aws_s3_bucket.data_lake.arn
        }
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_s3_bucket_logging" "data_lake" {
  bucket        = aws_s3_bucket.data_lake.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-ct-logs-" # RULE 58
  force_destroy = false
  tags          = var.tags
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
    status = "Enabled" # RULE 30
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
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

resource "aws_s3_bucket" "config_bucket" {
  bucket_prefix = "${var.project_name}-${var.environment}-config-" # RULE 58
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.config.arn
    }
    bucket_key_enabled = true
  }
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
    status = "Suspended" # Config bucket typically doesn't need versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AWSConfigBucketPermissionsCheck"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.config_bucket.arn
    }, {
      Sid    = "AWSConfigBucketDelivery"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.config_bucket.arn}/AWSConfig/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" : "bucket-owner-full-control"
        }
      }
    }]
  })
}

# VPC Endpoints (RULE 43)
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.logs"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.kms"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.ssm"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.ec2"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  private_dns_enabled = true
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  tags              = var.tags
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days # RULE 13, CloudWatch Logs (AVD-AWS-0017)
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE 38, CloudWatch Logs (AVD-AWS-0017)
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "guardduty" {
  name              = "/aws/guardduty/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# VPC Flow Logs (RULE 13)
resource "aws_flow_log" "main" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn # RULE 59
  traffic_type         = "ALL"
  vpc_id               = data.terraform_remote_state.networking.outputs.vpc_id
  log_destination_type = "cloud-watch-logs"
}

# CloudTrail (RULE 38)
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  tags                          = var.tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::"] # All S3 buckets
    }
  }
}

# AWS Config (RULE 34)
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config.arn
  recording_group {
    all_supported              = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name          = "${var.project_name}-${var.environment}-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "${var.project_name}-${var.environment}-s3-public-read-prohibited"
  description = "Checks that your S3 buckets do not allow public read access."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "${var.project_name}-${var.environment}-rds-storage-encrypted"
  description = "Checks whether the Amazon RDS DB instance or its snapshot is encrypted at rest."
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "${var.project_name}-${var.environment}-iam-root-access-key-check"
  description = "Checks whether the AWS Account root user has an access key."
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "${var.project_name}-${var.environment}-encrypted-volumes"
  description = "Checks whether Amazon Elastic Block Store (EBS) volumes that are attached to Amazon EC2 instances are encrypted."
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "${var.project_name}-${var.environment}-multi-region-cloudtrail-enabled"
  description = "Checks whether AWS CloudTrail is enabled in your AWS account."
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name        = "${var.project_name}-${var.environment}-s3-sse-enabled"
  description = "Checks whether your Amazon S3 buckets have server-side encryption enabled."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "vpc_flow_logs_enabled" {
  name        = "${var.project_name}-${var.environment}-vpc-flow-logs-enabled"
  description = "Checks whether Amazon VPC flow logs are enabled for your VPC."
  source {
    owner             = "AWS"
    source_identifier = "VPC_FLOW_LOGS_ENABLED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "cloud_trail_encryption_enabled" {
  name        = "${var.project_name}-${var.environment}-cloudtrail-encryption-enabled"
  description = "Checks whether AWS CloudTrail is configured to use AWS KMS encryption for log files."
  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }
  tags = var.tags
}

resource "aws_config_config_rule" "guardduty_enabled_centralized" {
  name        = "${var.project_name}-${var.environment}-guardduty-enabled"
  description = "Checks whether Amazon GuardDuty is enabled in your AWS account."
  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }
  tags = var.tags
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

# SNS Topic for GuardDuty Findings
resource "aws_sns_topic" "guardduty_findings" {
  name              = "${var.project_name}-${var.environment}-guardduty-findings"
  kms_master_key_id = aws_kms_key.main.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "guardduty_findings" {
  arn = aws_sns_topic.guardduty_findings.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowGuardDutyToPublish"
      Effect    = "Allow"
      Principal = { Service = "guardduty.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.guardduty_findings.arn
    }]
  })
}

# EventBridge Rule for GuardDuty Findings
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.project_name}-${var.environment}-guardduty-findings-rule"
  description = "Route GuardDuty findings to SNS topic"
  event_pattern = jsonencode({
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"]
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "guardduty_findings_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.guardduty_findings.arn
}

# Security Hub (RULE 33)
resource "aws_securityhub_account" "main" {
  # No tags argument
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  # No tags argument
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  # No tags argument
}

# SNS Topic for Alarms (RULE 45)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.main.arn
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
  # No tags argument
}

# CloudWatch Metric Filters and Alarms (CloudWatch security metric filters, RULE 35)
resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "${var.project_name}-${var.environment}-root-account-usage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "RootAccountUsageCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
  # No tags argument
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "${var.project_name}-${var.environment}-root-account-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_account_usage.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_account_usage.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account is used"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "console_login_without_mfa" {
  name           = "${var.project_name}-${var.environment}-console-login-without-mfa"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "ConsoleLoginWithoutMFACount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
  # No tags argument
}

resource "aws_cloudwatch_metric_alarm" "console_login_without_mfa" {
  alarm_name          = "${var.project_name}-${var.environment}-console-login-without-mfa-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.console_login_without_mfa.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.console_login_without_mfa.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login occurs without MFA"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  metric_transformation {
    name          = "UnauthorizedAPICallsCount"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
  # No tags argument
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-calls-alarm"
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

# AWS Backup (RULE 41)
resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn
  tags        = var.tags
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily-s3-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)" # Daily at 05:00 UTC

    lifecycle {
      delete_after = 35 # Retain for 35 days
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "s3_data_lake_selection" {
  name          = "${var.project_name}-${var.environment}-s3-data-lake-selection"
  plan_id       = aws_backup_plan.main.id
  iam_role_arn  = aws_iam_role.backup.arn
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Name"
    value = aws_s3_bucket.data_lake.id # Target by bucket ID
  }
  # No tags argument
}

# Secrets Manager (RULE 49)
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-" # RULE 15
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30 # RULE 15
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "db_credentials" {
  secret_arn = aws_secretsmanager_secret.db_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "EnableRootAccess"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "secretsmanager:*"
      Resource  = "*"
    }]
  })
}

resource "aws_secretsmanager_secret" "app_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-app-credentials-" # RULE 15
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30 # RULE 15
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "app_credentials" {
  secret_arn = aws_secretsmanager_secret.app_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "EnableRootAccess"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "secretsmanager:*"
      Resource  = "*"
    }]
  })
}

# RULE: Secrets Manager rotation (requires a Lambda function for actual rotation)
# resource "aws_secretsmanager_secret_rotation" "db_credentials" {
#   secret_id = aws_secretsmanager_secret.db_credentials.id
#   rotation_lambda_arn = "arn:aws:lambda:..." # Placeholder: requires a Lambda function ARN
#   rotation_rules {
#     automatically_after_days = 30
#   }
# }

# resource "aws_secretsmanager_secret_rotation" "app_credentials" {
#   secret_id = aws_secretsmanager_secret.app_credentials.id
#   rotation_lambda_arn = "arn:aws:lambda:..." # Placeholder: requires a Lambda function ARN
#   rotation_rules {
#     automatically_after_days = 30
#   }
# }

resource "aws_s3_bucket" "cloudtrail_logs_access" {
  bucket_prefix = "${var.project_name}-${var.environment}-ct-access-" # RULE 58
  force_destroy = false # Production setting
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_access_logs.arn # Using the s3_access_logs key
    }
    bucket_key_enabled = true
  }
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
    status = "Suspended" # Log buckets typically don't need versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_logs" { # Renamed from cloudtrail_logs_access to be clearer
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "config_bucket_logging" {
  bucket        = aws_s3_bucket.config_bucket.id
  target_bucket = aws_s3_bucket.config_bucket.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_versioning" "s3_access_logs_versioning" {
  bucket = aws_s3_bucket.s3_access_logs.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_versioning" "cloudtrail_logs_access_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_logging" "s3_access_logs_logging" {
  bucket        = aws_s3_bucket.s3_access_logs.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "cloudtrail_logs_access_logging" {
  bucket        = aws_s3_bucket.cloudtrail_logs_access.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}
