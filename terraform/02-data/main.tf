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

resource "aws_kms_key" "s3" {
  description             = "${var.project_name}-${var.environment}-s3-cmk"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "random_id" "kms_s3_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-s3-${random_id.kms_s3_suffix.hex}"
  target_key_id = aws_kms_key.s3.key_id
}

# S3 Access Logs Bucket
resource "aws_s3_bucket" "s3_access_logs" {
  bucket        = "${var.project_name}-${var.environment}-s3-access-logs"
  force_destroy = false # RULE 30: force_destroy = false for production
  tags          = var.tags
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
    status = "Enabled" # RULE 30: Enabled for production
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30: BucketOwnerEnforced
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    filter {}
    expiration {
      days = 365 # Retain logs for 1 year
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "s3_access_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketPolicy"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.s3_training_data.arn
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "S3BucketPolicyForModelArtifacts"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.s3_model_artifacts.arn
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# S3 Training Data Bucket
resource "aws_s3_bucket" "s3_training_data" {
  bucket        = var.s3_training_data_bucket_name
  force_destroy = false # RULE 30: force_destroy = false for production
  tags          = var.tags
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
    status = "Enabled" # RULE 30: Enabled for production
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30: BucketOwnerEnforced
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_training_data" {
  bucket = aws_s3_bucket.s3_training_data.id
  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}
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

# S3 Model Artifacts Bucket
resource "aws_s3_bucket" "s3_model_artifacts" {
  bucket        = var.s3_model_artifacts_bucket_name
  force_destroy = false # RULE 30: force_destroy = false for production
  tags          = var.tags
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
    status = "Enabled" # RULE 30: Enabled for production
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced" # RULE 30: BucketOwnerEnforced
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_model_artifacts" {
  bucket = aws_s3_bucket.s3_model_artifacts.id
  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}
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


resource "aws_s3_bucket_logging" "s3_access_logs_logging" {
  bucket        = aws_s3_bucket.s3_access_logs.id
  target_bucket = aws_s3_bucket.s3_access_logs.id
  target_prefix = "access-logs/"
}
