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
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Keys
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

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds"
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

resource "aws_kms_alias" "elasticache" {
  name          = "alias/${var.project_name}-${var.environment}-elasticache"
  target_key_id = aws_kms_key.elasticache.key_id
}

resource "aws_kms_key" "s3_assets" {
  description             = "${var.project_name}-${var.environment}-s3-assets-cmk"
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
            "kms:EncryptionContext:aws:s3:arn" : "arn:aws:s3:::${var.project_name}-${var.environment}-app-assets-*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "s3_assets" {
  name          = "alias/${var.project_name}-${var.environment}-s3-assets"
  target_key_id = aws_kms_key.s3_assets.key_id
}

resource "aws_kms_key" "s3_alb_logs_encryption" {
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
            "kms:EncryptionContext:aws:s3:arn" : "arn:aws:s3:::${var.project_name}-${var.environment}-alb-logs-*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "s3_alb_logs_encryption" {
  name          = "alias/${var.project_name}-${var.environment}-s3-alb-logs"
  target_key_id = aws_kms_key.s3_alb_logs_encryption.key_id
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

# IAM Roles
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "three-tier-web-app-produc-rds-monitor-" # Shortened role name per RULE 58
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

# RDS
resource "aws_db_parameter_group" "postgres" {
  name_prefix = "${var.project_name}-${var.environment}-pg-"
  family      = "postgres15"
  description = "PostgreSQL parameter group for ${var.project_name} ${var.environment}"
  tags        = var.tags

  parameter {
    name  = "log_statement"
    value = "all"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "main" {
  identifier                    = "${var.project_name}-${var.environment}-db"
  engine                        = "postgres"
  engine_version                = "15.5"
  instance_class                = var.db_instance_class
  allocated_storage             = 200
  storage_type                  = "gp2"
  db_subnet_group_name          = data.terraform_remote_state.networking.outputs.db_subnet_group_name
  vpc_security_group_ids        = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  multi_az                      = true
  username                      = var.db_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds.arn
  port                          = 5432
  parameter_group_name          = aws_db_parameter_group.postgres.name
  storage_encrypted             = true
  kms_key_id                    = aws_kms_key.rds.arn
  backup_retention_period       = 30
  skip_final_snapshot           = false
  deletion_protection           = true
  monitoring_interval           = 60
  monitoring_role_arn           = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled  = local.enable_performance_insights
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null
  tags                          = var.tags


  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]

  at_rest_encryption_enabled = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-"
  kms_key_id              = aws_kms_key.rds.arn # Using RDS KMS key for DB credentials
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache
resource "aws_security_group" "elasticache" {
  name        = "${var.project_name}-${var.environment}-elasticache-sg"
  description = "Security group for ElastiCache Redis - allows ingress from application tier"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags

  ingress {
    description     = "Redis from App tier"
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }

  egress {
    description = "All traffic within VPC"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet-group"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.project_name}-${var.environment}-redis"
  description                   = "ElastiCache Redis replication group for ${var.project_name} ${var.environment}"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = var.elasticache_node_type
  num_cache_clusters            = var.az_count # Primary + replica for 2 AZs
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [aws_security_group.elasticache.id]
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  kms_key_id                    = aws_kms_key.elasticache.arn
  tags                          = var.tags
}

# S3 Buckets
resource "aws_s3_bucket" "s3_assets" {
  bucket_prefix = "three-tier-web-app-produc-app-assets-"
  force_destroy = false
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_assets" {
  bucket = aws_s3_bucket.s3_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_assets.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_assets" {
  bucket                  = aws_s3_bucket.s3_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_assets" {
  bucket = aws_s3_bucket.s3_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_assets" {
  bucket = aws_s3_bucket.s3_assets.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "s3_alb_logs" {
  bucket_prefix = "three-tier-web-app-producti-alb-logs-"
  force_destroy = false
  tags          = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_alb_logs_encryption.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_alb_logs" {
  bucket                  = aws_s3_bucket.s3_alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_alb_logs" {
  bucket = aws_s3_bucket.s3_alb_logs.id
  rule {
    filter {}

    id     = "log_retention"
    status = "Enabled"
    expiration {
      days = 90
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

# CloudWatch Log Group for RDS Enhanced Monitoring
resource "aws_cloudwatch_log_group" "rds_enhanced_monitoring" {
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/enhanced-monitoring"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}


resource "aws_s3_bucket_logging" "s3_assets_logging" {
  bucket        = aws_s3_bucket.s3_assets.id
  target_bucket = aws_s3_bucket.s3_assets.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "s3_alb_logs_logging" {
  bucket        = aws_s3_bucket.s3_alb_logs.id
  target_bucket = aws_s3_bucket.s3_alb_logs.id
  target_prefix = "access-logs/"
}
