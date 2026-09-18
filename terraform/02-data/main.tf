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

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "random_id" "kms_elasticache_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
}

# KMS Keys and Aliases
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name}-${var.environment} general purpose"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-${random_id.kms_main_suffix.hex}"
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
        Sid    = "AllowRDSUseOfKey"
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
        Sid    = "AllowElastiCacheUseOfKey"
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
  name          = "alias/${var.project_name}-${var.environment}-elasticache-${random_id.kms_elasticache_suffix.hex}"
  target_key_id = aws_kms_key.elasticache.key_id
}

# IAM Roles
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
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# S3 Buckets
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.project_name}-${var.environment}-alb-logs"
  force_destroy = false # RULE 16
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
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

resource "aws_s3_bucket" "flow_logs" {
  bucket        = "${var.project_name}-${var.environment}-flow-logs"
  force_destroy = false # RULE 16
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket                  = aws_s3_bucket.flow_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket" "app_assets" {
  bucket        = "${var.project_name}-${var.environment}-app-assets"
  force_destroy = false # RULE 16
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket                  = aws_s3_bucket.app_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets.id
  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
    filter {}
    # Intelligent tiering is configured on the bucket itself, not via lifecycle rules.
    # This rule is a placeholder for other lifecycle management if needed.
    # For intelligent tiering, AWS manages transitions automatically.
    expiration {
      days = 3650 # Long retention for assets
    }
  }
}

# RDS
resource "aws_db_parameter_group" "postgres" {
  name_prefix = "${var.project_name}-${var.environment}-postgres-param-group-" # RULE 26
  family      = "postgres15"
  description = "PostgreSQL parameter group for ${var.project_name}-${var.environment}"
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
  identifier                     = "${var.project_name}-${var.environment}-db"
  engine                         = "postgres"
  engine_version                 = "15.5"
  instance_class                 = var.db_instance_class
  allocated_storage              = 100
  storage_type                   = "gp2"
  storage_encrypted              = true
  kms_key_id                     = aws_kms_key.rds.arn
  multi_az                       = true
  db_subnet_group_name           = data.terraform_remote_state.networking.outputs.db_subnet_group_name
  vpc_security_group_ids         = [data.terraform_remote_state.networking.outputs.db_security_group_id]
  db_name                        = var.db_name
  username                       = var.db_username
  manage_master_user_password    = true # RULE 60
  master_user_secret_kms_key_id  = aws_kms_key.rds.arn
  port                           = 5432
  publicly_accessible            = false
  skip_final_snapshot            = false # RULE 16
  deletion_protection            = true  # RULE 16
  backup_retention_period        = 30
  parameter_group_name           = aws_db_parameter_group.postgres.name
  iam_database_authentication_enabled = true
  monitoring_interval            = 60 # RULE 50
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn # RULE 50
  performance_insights_enabled   = local.enable_performance_insights
  performance_insights_retention_period = local.enable_performance_insights ? 7 : null
  tags                           = var.tags

  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
}

# ElastiCache
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-cache-subnet-group" # RULE 54
  subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids
  description = "ElastiCache subnet group for ${var.project_name}-${var.environment}"
  tags        = var.tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "redis-cluster-${var.project_name}-${var.environment}"
  description                   = "Redis replication group for ${var.project_name}-${var.environment}"
  engine                        = "redis"
  engine_version                = "7.0" # Default to a recent stable version
  node_type                     = var.elasticache_node_type
  num_cache_clusters            = 2 # For Multi-AZ with automatic failover
  automatic_failover_enabled    = true
  subnet_group_name             = aws_elasticache_subnet_group.main.name
  security_group_ids            = [data.terraform_remote_state.networking.outputs.elasticache_security_group_id] # Assuming this output exists
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  kms_key_id                    = aws_kms_key.elasticache.arn
  snapshot_retention_limit      = 7
  tags                          = var.tags
}

resource "aws_iam_role" "db_proxy" {
  name_prefix = "production-three-tier-p-db-proxy-role-" # RULE 26
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
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy" "db_proxy_secrets_manager" {
  name = "${var.project_name}-${var.environment}-db-proxy-secrets-policy"
  role = aws_iam_role.db_proxy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.db_credentials.arn
    }]
  })
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-" # RULE 15
  kms_key_id              = aws_kms_key.main.arn # RULE 49
  recovery_window_in_days = 30 # RULE 15
  tags                    = var.tags
  lifecycle {
    create_before_destroy = true # RULE 15
  }
}

resource "aws_db_proxy" "main" {
  name                   = "${var.project_name}-${var.environment}-proxy"
  engine_family          = "POSTGRESQL" # From rds_primary engine
  require_tls            = true # RULE 40
  role_arn               = aws_iam_role.db_proxy.arn
  vpc_subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.db_security_group_id]

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "REQUIRED" # From blueprint config
    secret_arn  = aws_secretsmanager_secret.db_credentials.arn
  }
  tags = var.tags
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name
  connection_pool_config {
    connection_borrow_timeout = 120
    max_connections_percent   = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_s3_bucket" "cloudtrail_s3" {
  bucket_prefix       = "production-three-tie-cloudtrail-logs-" # RULE 58
  force_destroy       = false # RULE 30
  tags                = var.tags

  object_lock_configuration {
    object_lock_enabled = "Enabled" # String for the configuration block
    rule {
      default_retention {
        mode = "GOVERNANCE" # From blueprint config
        days = 365 # From blueprint config
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_s3" {
  bucket                  = aws_s3_bucket.cloudtrail_s3.id
  block_public_acls       = true # RULE 30
  block_public_policy     = true # RULE 30
  ignore_public_acls      = true # RULE 30
  restrict_public_buckets = true # RULE 30
}

resource "aws_s3_bucket_versioning" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail_s3.id
  versioning_configuration {
    status = "Enabled" # RULE 30
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail_s3.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail_s3.id
  rule {
    id     = "cloudtrail-retention"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_s3" {
  bucket = aws_s3_bucket.cloudtrail_s3.id
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
        Resource = aws_s3_bucket.cloudtrail_s3.arn
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
        Resource = "${aws_s3_bucket.cloudtrail_s3.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}


resource "aws_s3_bucket_logging" "alb_logs_logging" {
  bucket        = aws_s3_bucket.alb_logs.id
  target_bucket = aws_s3_bucket.alb_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "flow_logs_logging" {
  bucket        = aws_s3_bucket.flow_logs.id
  target_bucket = aws_s3_bucket.flow_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "app_assets_logging" {
  bucket        = aws_s3_bucket.app_assets.id
  target_bucket = aws_s3_bucket.app_assets.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "cloudtrail_s3_logging" {
  bucket        = aws_s3_bucket.cloudtrail_s3.id
  target_bucket = aws_s3_bucket.cloudtrail_s3.id
  target_prefix = "access-logs/"
}
