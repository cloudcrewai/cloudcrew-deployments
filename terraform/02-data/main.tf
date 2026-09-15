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

locals {
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Keys and Aliases
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-general-cmk"
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
      },
      {
        Sid    = "AllowSNSTopic"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
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
  name          = "alias/${var.project_name}-${var.environment}-main-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

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
        Sid    = "AllowRDSServicePrincipal"
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
  tags = var.tags
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.rds.key_id
}

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
        Sid    = "AllowElastiCacheServicePrincipal"
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
  tags = var.tags
}

resource "random_id" "kms_elasticache_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "elasticache" {
  name          = "alias/${var.project_name}-${var.environment}-elasticache-${random_id.kms_elasticache_suffix.hex}"
  target_key_id = aws_kms_key.elasticache.key_id
}

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
        Sid    = "AllowS3ServicePrincipal"
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
        Condition = {
          StringEquals = {
            "kms:ViaService" : "s3.${data.aws_region.current.name}.amazonaws.com"
          },
          ArnLike = {
            "kms:EncryptionContext:aws:s3:arn" : "arn:aws:s3:::*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_key" "s3_alb_logs" {
  description             = "${var.project_name}-${var.environment}-s3-alb-logs-cmk"
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
        Sid    = "AllowS3ServicePrincipal"
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
        Condition = {
          StringEquals = {
            "kms:ViaService" : "s3.${data.aws_region.current.name}.amazonaws.com"
          },
          ArnLike = {
            "kms:EncryptionContext:aws:s3:arn" : "arn:aws:s3:::*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_s3_alb_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3_alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-s3-alb-logs-${random_id.kms_s3_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.s3_alb_logs.key_id
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
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# IAM Roles and Policies
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "prod-three-tier-web-pr-rds-monitoring-"
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

resource "aws_iam_role" "flow_logs" {
  name_prefix = "${var.project_name}-flow-logs-role-"
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
  name = "${var.project_name}-flow-logs-policy"
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
  name_prefix = "prod-three-tier-web-p-cloudtrail-role-"
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
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail.name}:*"
      },
      {
        Action   = "logs:DescribeLogGroups"
        Effect   = "Allow"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

resource "aws_iam_role" "config" {
  name_prefix = "prod-three-tier-web-produ-config-role-"
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

resource "aws_iam_role_policy_attachment" "config_recorder" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "config_delivery_s3" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # More specific policy needed for production
}

resource "aws_iam_role_policy_attachment" "config_delivery_sns" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" # More specific policy needed for production
}

resource "aws_iam_role" "backup" {
  name_prefix = "prod-three-tier-web-produ-backup-role-"
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

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "root_usage" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}-root-usage"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "mfa_disabled" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}-mfa-disabled"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "unauthorized_api" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}-unauthorized-api"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# VPC Flow Logs
# VPC Endpoints
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_endpoint_type = "Interface"
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG allows access to Secrets Manager
  private_dns_enabled = true
  tags              = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_endpoint_type = "Interface"
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kms"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG allows access to KMS
  private_dns_enabled = true
  tags              = var.tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = data.terraform_remote_state.networking.outputs.private_route_table_ids
  tags              = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_endpoint_type = "Interface"
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id] # Assuming DB SG allows access to CloudWatch Logs
  private_dns_enabled = true
  tags              = var.tags
}

# RDS
resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-postgres-param-group-"
  family      = "postgres15"
  description = "PostgreSQL 15 parameter group for ${var.project_name} ${var.environment}"
  tags        = var.tags

  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # Log statements that take longer than 1 second
  }
  parameter {
    name  = "log_statement"
    value = "ddl" # Log all DDL statements
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "main" {
  identifier                     = "${var.project_name}-${var.environment}-rds"
  engine                         = "postgres"
  engine_version                 = "15.5"
  instance_class                 = var.db_instance_class
  allocated_storage              = 200
  storage_type                   = "gp2"
  db_name                        = var.db_name
  username                       = var.db_username
  manage_master_user_password    = true
  master_user_secret_kms_key_id  = aws_kms_key.rds.arn
  db_subnet_group_name           = data.terraform_remote_state.networking.outputs.db_subnet_group_name
  vpc_security_group_ids         = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  multi_az                       = true
  storage_encrypted              = true
  kms_key_id                     = aws_kms_key.rds.arn
  deletion_protection            = true
  skip_final_snapshot            = false
  backup_retention_period        = 30
  iam_database_authentication_enabled = true
  publicly_accessible            = false
  parameter_group_name           = aws_db_parameter_group.main.name
  monitoring_interval            = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled   = local.enable_performance_insights
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null
  tags                           = var.tags

  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
}

# ElastiCache
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-cache-subnet-group"
  subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids
  description = "ElastiCache subnet group for ${var.project_name} ${var.environment}"
  tags        = var.tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.project_name}-${var.environment}-redis"
  description                   = "ElastiCache Redis replication group for ${var.project_name} ${var.environment}"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = var.elasticache_node_type
  num_cache_clusters            = 2 # Primary + 1 Replica for 2 AZs
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  kms_key_id                    = aws_kms_key.elasticache.arn
  snapshot_retention_limit      = 7
  tags                          = var.tags
}

# S3 Buckets
resource "aws_s3_bucket" "assets" {
  bucket_prefix = "prod-three-tier-web-produ-app-assets-"
  force_destroy = false # Production bucket
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    filter {}

    id     = "expire-noncurrent-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket_prefix = "prod-three-tier-web-alb-access-logs-"
  force_destroy = false # Production bucket
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_alb_logs.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    filter {}

    id     = "log_retention"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowALBLogging"
      Effect = "Allow"
      Principal = {
        Service = "elasticloadbalancing.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Config
resource "aws_s3_bucket" "config_logs" {
  bucket_prefix = "prod-three-tier-web-prod-config-logs-"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket                  = aws_s3_bucket.config_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_logs.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_logs.arn}/AWSConfig/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic" "config_notifications" {
  name              = "${var.project_name}-${var.environment}-config-notifications"
  kms_master_key_id = aws_kms_key.main.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowConfigNotifications"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config_notifications.arn
    }]
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
  s3_bucket_name = aws_s3_bucket.config_logs.id
  sns_topic_arn  = aws_sns_topic.config_notifications.arn
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "multi-region-cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

# AWS Backup
resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.main.arn
  tags        = var.tags
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 35
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "rds" {
  name          = "${var.project_name}-${var.environment}-rds-selection"
  plan_id       = aws_backup_plan.main.id
  iam_role_arn  = aws_iam_role.backup.arn
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Project"
    value = var.project_name
  }
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.environment
  }
  resources = [aws_db_instance.main.arn]
}

# GuardDuty
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

# Security Hub
resource "aws_securityhub_account" "main" {
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# CloudTrail
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket_prefix = "prod-three-tier-web-cloudtrail-logs-"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
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

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  kms_key_id                    = aws_kms_key.s3.arn # CloudTrail logs are encrypted with S3 KMS key
  tags                          = var.tags
}

# CloudWatch Alarms and Metric Filters
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
}

resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "${var.project_name}-${var.environment}-root-usage-filter"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "RootAccountUsage"
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
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mfa_disabled" {
  name           = "${var.project_name}-${var.environment}-mfa-disabled-filter"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "ConsoleLoginWithoutMFA"
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
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-filter"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name          = "UnauthorizedAPICalls"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
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
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
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
  threshold           = 20000000000 # 20 GB in bytes
  alarm_description   = "RDS Free Storage Space is less than 20GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-elasticache-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ElastiCache CPU Utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    ReplicationGroup = aws_elasticache_replication_group.main.replication_group_id
  }
  tags = var.tags
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


resource "aws_s3_bucket_logging" "assets_logging" {
  bucket        = aws_s3_bucket.assets.id
  target_bucket = aws_s3_bucket.assets.id
  target_prefix = "access-logs/"
}
