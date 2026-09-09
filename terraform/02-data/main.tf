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

resource "aws_kms_key" "s3_data" {
  description             = "${var.project_name}-${var.environment}-s3-data-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3_data" {
  name          = "alias/${var.project_name}-${var.environment}-s3-data"
  target_key_id = aws_kms_key.s3_data.key_id
}

resource "aws_kms_key" "s3_access_logs" {
  description             = "${var.project_name}-${var.environment}-s3-access-logs-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3_access_logs" {
  name          = "alias/${var.project_name}-${var.environment}-s3-access-logs"
  target_key_id = aws_kms_key.s3_access_logs.key_id
}

resource "aws_s3_bucket" "s3_access_logs" {
  bucket = "${var.project_name}-${var.environment}-s3-access-logs"
  tags   = var.tags
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
    status = "Disabled" # Log buckets typically do not need versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
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

resource "aws_s3_bucket_lifecycle_configuration" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    filter {}

    id     = "expire-old-logs"
    status = "Enabled"
    expiration {
      days = 90 # Retain logs for 90 days
    }
  }
}

resource "aws_s3_bucket_policy" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketPolicyForS3AccessLogs"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = [
              aws_s3_bucket.s3_training_data.arn,
              aws_s3_bucket.s3_model_artifacts.arn
            ]
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "s3_training_data" {
  bucket = "${var.project_name}-${var.environment}-ml-training-data"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_training_data" {
  bucket                  = aws_s3_bucket.s3_training_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    filter {}

    id     = "expire-noncurrent-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_logging" "s3_training_data" {
  bucket        = aws_s3_bucket.s3_training_data.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "s3-training-data/"
}

resource "aws_s3_bucket" "s3_model_artifacts" {
  bucket = "${var.project_name}-${var.environment}-ml-model-artifacts"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_model_artifacts" {
  bucket                  = aws_s3_bucket.s3_model_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    filter {}

    id     = "expire-noncurrent-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_logging" "s3_model_artifacts" {
  bucket        = aws_s3_bucket.s3_model_artifacts.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "s3-model-artifacts/"
}


resource "aws_s3_bucket_versioning" "s3_access_logs_versioning" {
  bucket = aws_s3_bucket.s3_access_logs.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_logging" "s3_access_logs_logging" {
  bucket        = aws_s3_bucket.s3_access_logs.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "access-logs/"
}
