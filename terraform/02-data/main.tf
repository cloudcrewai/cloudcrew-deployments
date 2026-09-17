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
  # RULE 14b: Performance Insights enabled only for supported instance classes
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
}

# KMS Keys and Aliases (RULE 17, RULE 29)
# KMS key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "${var.project_name}-${var.environment}-rds-cmk"
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
        Sid    = "AllowRDSServiceUse"
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
  tags = local.common_tags
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.rds.key_id
}

# KMS key for ElastiCache encryption
resource "aws_kms_key" "elasticache" {
  description             = "${var.project_name}-${var.environment}-elasticache-cmk"
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
        Sid    = "AllowElastiCacheServiceUse"
        Effect = "Allow"
        Principal = {
          Service = "elasticache.amazonaws.com"
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
  tags = local.common_tags
}

resource "random_id" "kms_elasticache_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "elasticache" {
  name          = "alias/${var.project_name}-${var.environment}-elasticache-${random_id.kms_elasticache_suffix.hex}"
  target_key_id = aws_kms_key.elasticache.key_id
}

# KMS key for S3 encryption
resource "aws_kms_key" "s3" {
  description             = "${var.project_name}-${var.environment}-s3-cmk"
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
        Sid    = "AllowS3ServiceUse"
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
  tags = local.common_tags
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.s3.key_id
}

# KMS key for CloudWatch Logs (RULE 22)
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
  tags = local.common_tags
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "logs" {
  # RULE 29: the random_id suffix makes the alias name unique per deploy, so a
  # destroy+re-deploy with the same project_name/environment never collides with
  # an alias left behind by the KMS key's pending-deletion window. The alias stays
  # human-readable in the console for audit navigation.
  # RULE 27: Phase-scoped KMS logs alias names.
  name          = "alias/${var.project_name}-${var.environment}-data-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# KMS key for Secrets Manager (RULE 49)
resource "aws_kms_key" "secrets" {
  description             = "${var.project_name}-${var.environment}-secrets-cmk"
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
        Sid    = "AllowSecretsManagerServiceUse"
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
      },
      {
        Sid    = "AllowDBProxyRoleDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.db_proxy.arn
        }
        Action   = "kms:Decrypt"
        Resource = "*"
      }
    ]
  })
  tags = local.common_tags
}

resource "random_id" "kms_secrets_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project_name}-${var.environment}-secrets-${random_id.kms_secrets_suffix.hex}"
  target_key_id = aws_kms_key.secrets.key_id
}

# CloudWatch Log Groups (RULE 39, RULE 13b)
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/cluster/${var.project_name}-${var.environment}-rds"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE 38: CloudTrail is audit-relevant
  kms_key_id        = aws_kms_key.logs.arn
  tags              = local.common_tags
}

# SNS Topic for Alarms (RULE 45)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.secrets.arn # Using secrets KMS key for SNS encryption
  tags              = local.common_tags
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

# IAM Roles and Policies
# IAM Role for RDS Enhanced Monitoring (RULE 50)
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "production-three-tier-rds-monitoring-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
  tags = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# IAM Role for CloudTrail (RULE 38)
resource "aws_iam_role" "cloudtrail" {
  name_prefix = "production-three-tier-cloudtrail-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })
  tags = local.common_tags
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
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 13b
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

# IAM Role for AWS Backup (RULE 41)
resource "aws_iam_role" "backup" {
  name_prefix = "production-three-tier-pro-backup-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
  tags = local.common_tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# IAM Role for RDS Proxy (RULE 40)
resource "aws_iam_role" "db_proxy" {
  name_prefix        = "production-three-tier-produc-db-proxy-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })
  tags = local.common_tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_policy" "db_proxy_secrets_access" {
  name_prefix = "${var.project_name}-${var.environment}-db-proxy-secrets-" # RULE 26
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      },
      {
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = aws_kms_key.secrets.arn
      }
    ]
  })
  tags = local.common_tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy_attachment" "db_proxy_secrets_access" {
  role       = aws_iam_role.db_proxy.name
  policy_arn = aws_iam_policy.db_proxy_secrets_access.arn
}

# S3 Buckets and Companion Resources
# S3 Bucket for CloudTrail Logs (RULE 38, RULE 30)
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-${var.environment}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # RULE 30
  tags          = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true # RULE 30
  block_public_policy     = true # RULE 30
  ignore_public_acls      = true # RULE 30
  restrict_public_buckets = true # RULE 30
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled" # RULE 30: Enabled for audit/state buckets
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30
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

# S3 Bucket for VPC Flow Logs (s3_flow_logs component)
resource "aws_s3_bucket" "s3_flow_logs" {
  bucket = "${var.project_name}-${var.environment}-flow-logs" # RULE 58
  force_destroy = false # RULE 30
  tags          = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3_flow_logs" {
  bucket                  = aws_s3_bucket.s3_flow_logs.id
  block_public_acls       = true # RULE 30
  block_public_policy     = true # RULE 30
  ignore_public_acls      = true # RULE 30
  restrict_public_buckets = true # RULE 30
}

# RULE 30: Versioning not required for log sinks.
resource "aws_s3_bucket_ownership_controls" "s3_flow_logs" {
  bucket = aws_s3_bucket.s3_flow_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_flow_logs" {
  bucket = aws_s3_bucket.s3_flow_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_flow_logs" {
  bucket = aws_s3_bucket.s3_flow_logs.id
  rule {
    id     = "glacier_transition"
    status = "Enabled"
    filter {}
    transition {
      days          = 90 # From blueprint config: lifecycle_transition_glacier_days
      storage_class = "GLACIER"
    }
    expiration {
      days = 365 # Default expiration, RULE 23
    }
  }
}

# S3 Bucket for App Assets (s3_app_assets component)
resource "aws_s3_bucket" "s3_app_assets" {
  bucket = "${var.project_name}-${var.environment}-app-assets" # RULE 58
  force_destroy = false # RULE 30
  tags          = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3_app_assets" {
  bucket                  = aws_s3_bucket.s3_app_assets.id
  block_public_acls       = true # RULE 30
  block_public_policy     = true # RULE 30
  ignore_public_acls      = true # RULE 30
  restrict_public_buckets = true # RULE 30
}

resource "aws_s3_bucket_versioning" "s3_app_assets" {
  bucket = aws_s3_bucket.s3_app_assets.id
  versioning_configuration {
    status = "Enabled" # RULE 30: Enabled for production assets
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_app_assets" {
  bucket = aws_s3_bucket.s3_app_assets.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_app_assets" {
  bucket = aws_s3_bucket.s3_app_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_app_assets" {
  bucket = aws_s3_bucket.s3_app_assets.id
  rule {
    id     = "intelligent_tiering"
    status = "Enabled"
    filter {}
    transition {
      days          = 0 # Transition immediately to Intelligent-Tiering
      storage_class = "INTELLIGENT_TIERING"
    }
    expiration {
      days = 365 # Default expiration, RULE 23
    }
  }
}

# CloudTrail (RULE 38)
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  include_global_service_events = true # RULE 38
  kms_key_id                    = aws_kms_key.logs.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  sns_topic_name                = aws_sns_topic.alarms.arn
  tags                          = local.common_tags
}

# AWS Backup (RULE 41)
resource "aws_kms_key" "backup" {
  description             = "${var.project_name}-${var.environment}-backup-cmk"
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
        Sid    = "AllowBackupServiceUse"
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
  tags = local.common_tags
}

resource "random_id" "kms_backup_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-${var.environment}-backup-${random_id.kms_backup_suffix.hex}"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn
  tags        = local.common_tags
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)" # RULE 41

    lifecycle {
      delete_after = 35 # RULE 41
    }
  }
  tags = local.common_tags
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

# RDS PostgreSQL Primary (rds_primary component)
resource "aws_rds_cluster_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-pg-cluster-" # RULE 26, RULE 58
  family      = "aurora-postgresql15"
  description = "Aurora PostgreSQL 15 cluster parameter group for ${var.project_name}" # RULE 51

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # From blueprint config
  }
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements" # From blueprint config
  }
  tags = local.common_tags

  lifecycle {
    create_before_destroy = true # RULE 26
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${var.project_name}-${var.environment}-rds-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = "15.5"
  database_name                   = "${var.project_name}db"
  master_username                 = var.db_username
  manage_master_user_password     = true # RULE 60
  master_user_secret_kms_key_id   = aws_kms_key.rds.arn # RULE 60
  db_subnet_group_name            = data.terraform_remote_state.networking.outputs.db_subnet_group_name
  vpc_security_group_ids          = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  storage_encrypted               = true # Required
  kms_key_id                      = aws_kms_key.rds.arn # Required
  deletion_protection             = true # RULE 16: Required for production
  backup_retention_period         = 14 # From blueprint config
  iam_database_authentication_enabled = true # Required
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  preferred_backup_window         = "03:00-05:00"
  preferred_maintenance_window    = "sun:06:00-sun:07:00"
  tags                            = local.common_tags
}

resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${var.project_name}-${var.environment}-writer" # RULE 55
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.db_instance_class # From pricing hints: db.r6g.large
  engine              = aws_rds_cluster.main.engine
  promotion_tier      = 0 # Writer instance
  monitoring_interval = 60 # RULE 50
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled = local.enable_performance_insights # RULE 14b
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null # RULE 14b
  # RULE 14c: Never set performance_insights_kms_key_id
  publicly_accessible = false # Required
  tags                = local.common_tags
}

resource "aws_rds_cluster_instance" "reader" {
  identifier          = "${var.project_name}-${var.environment}-reader" # RULE 55
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.db_instance_class # From pricing hints: db.r6g.large
  engine              = aws_rds_cluster.main.engine
  promotion_tier      = 1 # Reader instance
  monitoring_interval = 60 # RULE 50
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled = local.enable_performance_insights # RULE 14b
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null # RULE 14b
  # RULE 14c: Never set performance_insights_kms_key_id
  publicly_accessible = false # Required
  tags                = local.common_tags
}

# Secrets Manager Secret for RDS Proxy (RULE 15, RULE 49)
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-" # RULE 15
  kms_key_id              = aws_kms_key.secrets.arn # RULE 49
  recovery_window_in_days = 30 # RULE 15
  tags                    = local.common_tags

  lifecycle {
    create_before_destroy = true # RULE 15
  }
}

# RDS Proxy (rds_proxy component) (RULE 40)
resource "aws_db_proxy" "main" {
  name                   = "${var.project_name}-${var.environment}-proxy"
  engine_family          = "POSTGRESQL" # From blueprint config
  require_tls            = true # Required
  role_arn               = aws_iam_role.db_proxy.arn
  vpc_subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming shared SG for DB/Proxy

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED" # From blueprint config: iam_auth_enabled
    secret_arn  = aws_secretsmanager_secret.db_credentials.arn
  }
  tags = local.common_tags
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name
  connection_pool_config {
    session_pinning_filters = ["EXCLUDE_VARIABLE_SETS"] # Default for PostgreSQL
  }
}

# ElastiCache Redis Replica (elasticache_replica component)
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-cache-subnet-group" # RULE 54
  subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids
  description = "ElastiCache subnet group for ${var.project_name}" # RULE 51
  tags        = local.common_tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.project_name}-${var.environment}-redis"
  description                   = "Redis replication group for ${var.project_name}"
  engine                        = "redis"
  engine_version                = "7.0" # From blueprint config
  node_type                     = var.elasticache_node_type # From pricing hints: cache.r6g.large
  num_cache_clusters            = 2 # For Multi-AZ with 2 AZs, without cluster mode
  automatic_failover_enabled    = true # Required for production
  at_rest_encryption_enabled    = true # Required
  transit_encryption_enabled    = true # From blueprint config, Required
  kms_key_id                    = aws_kms_key.elasticache.arn # Required
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming shared SG for DB/Cache
  maintenance_window            = "sun:05:00-sun:06:00" # Corrected from preferred_maintenance_window
  snapshot_retention_limit      = 7
  tags                          = local.common_tags
}

# CloudWatch Security Metric Filters and Alarms
# Root account usage (CIS 3.1)
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "${var.project_name}-${var.environment}-root-login-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "${var.project_name}-RootLogin"
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
  alarm_description   = "Alarm when root account is used"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = local.common_tags
}

# Console sign-in without MFA (CIS 3.2)
resource "aws_cloudwatch_log_metric_filter" "mfa_disabled_login" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-login-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "${var.project_name}-MFADisabledLogin"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_disabled_login" {
  alarm_name          = "${var.project_name}-${var.environment}-MFADisabledLoginAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_disabled_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_disabled_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login without MFA occurs"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = local.common_tags
}

# Unauthorized API calls (CIS 3.3)
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
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
  alarm_name          = "${var.project_name}-${var.environment}-UnauthorizedAPICallsAlarm"
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
  tags                = local.common_tags
}

# KMS Key for ALB Logs (s3_alb_logs)
resource "aws_kms_key" "alb_logs" {
  description             = "${var.project_name}-${var.environment}-alb-logs-cmk"
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
        Sid    = "AllowALBLogging"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
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

resource "random_id" "kms_alb_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-alb-logs-${random_id.kms_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.alb_logs.key_id
}

# KMS Key for DynamoDB
resource "aws_kms_key" "dynamodb" {
  description             = "${var.project_name}-${var.environment}-dynamodb-cmk"
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
        Sid    = "AllowDynamoDBService"
        Effect = "Allow"
        Principal = {
          Service = "dynamodb.amazonaws.com"
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

resource "random_id" "kms_dynamodb_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "dynamodb" {
  name          = "alias/${var.project_name}-${var.environment}-dynamodb-${random_id.kms_dynamodb_suffix.hex}"
  target_key_id = aws_kms_key.dynamodb.key_id
}

# S3 Bucket for ALB Logs (s3_alb_logs)
resource "aws_s3_bucket" "s3_alb_logs" {
  bucket        = "${var.project_name}-${var.environment}-alb-logs"
  force_destroy = false # RULE 30: force_destroy = false for production
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_alb_logs" {
  bucket                  = aws_s3_bucket.s3_alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.alb_logs.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}
    transition {
      days          = var.alb_logs_lifecycle_transition_ia_days
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = var.alb_logs_lifecycle_transition_glacier_days
      storage_class = "GLACIER"
    }
    expiration {
      days = var.alb_logs_lifecycle_expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowALBLogging"
      Effect = "Allow"
      Principal = {
        Service = "elasticloadbalancing.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.s3_alb_logs.arn}/*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

# DynamoDB Table (dynamodb)
resource "aws_dynamodb_table" "main" {
  name         = "${var.project_name}-${var.environment}-dynamodb"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key
  tags         = var.tags

  attribute {
    name = var.dynamodb_hash_key
    type = var.dynamodb_hash_key_type
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true
}

resource "aws_s3_bucket" "cloudtrail_logs_access" {
  bucket_prefix = "ct-access-logs-"
  force_destroy = var.log_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_access" {
  bucket                  = aws_s3_bucket.cloudtrail_logs_access.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_access" {
  # AES256, not the aws:kms CMK main_tf_v1.0.md:655 otherwise
  # mandates: an S3 server-access-logging TARGET bucket cannot
  # use SSE-KMS.  "The destination bucket must use Amazon S3
  # managed keys (SSE-S3). If the destination bucket uses
  # SSE-KMS, Amazon S3 might deliver log objects that are
  # encrypted with a key that you can't access."
  # -- docs.aws.amazon.com/AmazonS3/latest/userguide/
  #    enable-server-access-logging.html
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs_access" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_logs_access" {
  bucket        = aws_s3_bucket.cloudtrail_logs.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "s3_flow_logs_logging" {
  bucket        = aws_s3_bucket.s3_flow_logs.id
  target_bucket = aws_s3_bucket.s3_flow_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "s3_app_assets_logging" {
  bucket        = aws_s3_bucket.s3_app_assets.id
  target_bucket = aws_s3_bucket.s3_app_assets.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "s3_alb_logs_logging" {
  bucket        = aws_s3_bucket.s3_alb_logs.id
  target_bucket = aws_s3_bucket.s3_alb_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_versioning" "s3_flow_logs_versioning" {
  bucket = aws_s3_bucket.s3_flow_logs.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_versioning" "s3_alb_logs_versioning" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  versioning_configuration { status = "Enabled" }
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
