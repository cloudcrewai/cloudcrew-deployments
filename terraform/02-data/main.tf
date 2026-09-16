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

resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} data resources"
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
      },
      {
        Sid    = "AllowDynamoDBUseOfKey"
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
      },
      {
        Sid    = "AllowKinesisUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "kinesis.amazonaws.com"
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
  name          = "alias/${var.project_name}-${var.environment}-data-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_s3_bucket" "s3_archive" {
  bucket        = "${var.project_name}-${var.environment}-s3-archive"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "s3_archive" {
  bucket = aws_s3_bucket.s3_archive.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_archive" {
  bucket                  = aws_s3_bucket.s3_archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_archive" {
  bucket = aws_s3_bucket.s3_archive.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "s3_archive" {
  bucket = aws_s3_bucket.s3_archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_archive" {
  bucket = aws_s3_bucket.s3_archive.id
  rule {
    id     = "archive_to_glacier"
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

resource "aws_dynamodb_table" "dynamodb_aggregates" {
  name                          = "iot_aggregates"
  billing_mode                  = "PAY_PER_REQUEST"
  hash_key                      = "id"
  deletion_protection_enabled   = true
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.main.arn
  }
  attribute {
    name = "id"
    type = "S"
  }
  tags = var.tags
}

resource "aws_kinesis_stream" "kinesis_data_stream" {
  name              = "${var.project_name}-${var.environment}-kinesis-data-stream"
  shard_count       = 5
  retention_period  = 168 # Minimum 7 days (168 hours) per rule, overriding blueprint's 24 hours
  encryption_type   = "KMS"
  kms_key_id        = aws_kms_key.main.arn
  tags              = var.tags
}


resource "aws_s3_bucket_logging" "s3_archive_logging" {
  bucket        = aws_s3_bucket.s3_archive.id
  target_bucket = aws_s3_bucket.s3_archive.id
  target_prefix = "access-logs/"
}
