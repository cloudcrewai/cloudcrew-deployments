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
  az_list = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# KMS Keys and Aliases

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
  name          = "alias/${var.project_name}-${var.environment}-networking-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name}-${var.environment} general use"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_key" "flow_logs" {
  description             = "${var.project_name}-${var.environment}-flow-logs-cmk"
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

resource "random_id" "kms_flow_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${var.project_name}-${var.environment}-networking-flow-logs-${random_id.kms_flow_logs_suffix.hex}"
  target_key_id = aws_kms_key.flow_logs.key_id
}

resource "aws_kms_key" "cloudtrail" {
  description             = "${var.project_name}-${var.environment}-cloudtrail-cmk"
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
        Sid    = "AllowCloudTrail"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_cloudtrail_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-${var.environment}-networking-cloudtrail-${random_id.kms_cloudtrail_suffix.hex}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

resource "aws_kms_key" "config" {
  description             = "${var.project_name}-${var.environment}-config-cmk"
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
        Sid    = "AllowConfig"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_config_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "config" {
  name          = "alias/${var.project_name}-${var.environment}-networking-config-${random_id.kms_config_suffix.hex}"
  target_key_id = aws_kms_key.config.key_id
}

resource "aws_kms_key" "sns" {
  description             = "${var.project_name}-${var.environment}-sns-cmk"
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
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "kms:GenerateDataKey*"
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_sns_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "sns" {
  name          = "alias/${var.project_name}-${var.environment}-networking-sns-${random_id.kms_sns_suffix.hex}"
  target_key_id = aws_kms_key.sns.key_id
}

# S3 Buckets for Logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project_name}-${var.environment}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # RULE 38
  tags          = var.tags
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
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
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

resource "aws_s3_bucket" "config_logs" {
  bucket        = "${var.project_name}-${var.environment}-config-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket                  = aws_s3_bucket.config_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.config.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.project_name}-${var.environment}-alb-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false
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

# IAM Roles and Policies
resource "aws_iam_role" "flow_logs" {
  name_prefix = "prod-three-tier-web-pr-flow-logs-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-${var.environment}-flow-logs-policy"
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
        Sid    = "CloudTrailS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "${aws_s3_bucket.cloudtrail_logs.arn}/*",
          aws_s3_bucket.cloudtrail_logs.arn
        ]
      },
      {
        Sid    = "CloudTrailCloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
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

resource "aws_iam_role_policy" "config" {
  name = "${var.project_name}-${var.environment}-config-policy"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ConfigS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetBucketACL",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.config_logs.arn,
          "${aws_s3_bucket.config_logs.arn}/*"
        ]
      },
      {
        Sid    = "ConfigSNSPublish"
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.config_notifications.arn
      },
      {
        Sid    = "ConfigDescribe"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "cloudwatch:Describe*",
          "s3:GetBucketVersioning",
          "s3:GetBucketTagging",
          "s3:GetBucketPolicy",
          "s3:GetBucketLocation",
          "s3:GetBucketLogging",
          "s3:GetBucketWebsite",
          "s3:GetBucketNotification",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "iam:List*",
          "iam:Get*",
          "rds:Describe*",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "kms:DescribeKey",
          "kms:ListKeys",
          "kms:ListAliases",
          "lambda:GetFunctionConfiguration",
          "lambda:ListFunctions",
          "apigateway:GET",
          "elasticloadbalancing:Describe*",
          "autoscaling:Describe*",
          "ecs:Describe*",
          "ecs:List*",
          "eks:Describe*",
          "eks:List*",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "wafv2:ListWebACLs",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:ListResourcesForWebACL",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues",
          "sns:GetTopicAttributes",
          "sns:ListTopics",
          "guardduty:ListDetectors",
          "guardduty:GetDetector",
          "securityhub:DescribeHub",
          "securityhub:GetEnabledStandards",
          "securityhub:GetFindings",
          "securityhub:GetInsightResults",
          "securityhub:ListMembers",
          "securityhub:ListOrganizationAdminAccounts",
          "securityhub:ListInvitations",
          "securityhub:ListConfigurationPolicies",
          "securityhub:ListAutomationRules",
          "securityhub:ListFindingAggregators",
          "securityhub:ListSecurityControlDefinitions",
          "securityhub:ListStandards",
          "securityhub:ListStandardsControlAssociations",
          "securityhub:ListOrganizationConfiguration",
          "securityhub:ListConfigurationPolicies",
          "securityhub:ListAutomationRules",
          "securityhub:ListFindingAggregators",
          "securityhub:ListSecurityControlDefinitions",
          "securityhub:ListStandards",
          "securityhub:ListStandardsControlAssociations",
          "securityhub:ListOrganizationConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
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
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.project_name}-${var.environment}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-igw" })
}

# EIPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}" })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}" })
  depends_on    = [aws_internet_gateway.main]
}

# Subnets
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.project_name}-${var.environment}-public-${local.az_list[count.index]}", Tier = "public" })
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_list[count.index]
  tags              = merge(var.tags, { Name = "${var.project_name}-${var.environment}-private-${local.az_list[count.index]}", Tier = "private" })
}

resource "aws_subnet" "db" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = local.az_list[count.index]
  tags              = merge(var.tags, { Name = "${var.project_name}-${var.environment}-db-${local.az_list[count.index]}", Tier = "database" })
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-private-${count.index + 1}" })
}

resource "aws_route" "private_nat" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Database subnets have no route to internet or NAT gateway
resource "aws_route_table" "db" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.project_name}-${var.environment}-rt-db-${count.index + 1}" })
}

resource "aws_route_table_association" "db" {
  count          = var.az_count
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer - allows HTTPS inbound from internet"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "alb_ingress_http" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = var.alb_port_http
  to_port           = var.alb_port_http
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP from internet for redirect"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = var.alb_port_https
  to_port           = var.alb_port_https
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS from internet"
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for ECS Fargate application tasks"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow application traffic from ALB"
}

resource "aws_security_group_rule" "app_egress_to_vpc" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic within VPC"
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "db_ingress_from_app" {
  security_group_id        = aws_security_group.db.id
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow PostgreSQL from application tasks"
}

resource "aws_security_group_rule" "db_egress_to_vpc" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic within VPC"
}

resource "aws_security_group" "elasticache" {
  name        = "${var.project_name}-${var.environment}-elasticache-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "elasticache_ingress_from_app" {
  security_group_id        = aws_security_group.elasticache.id
  type                     = "ingress"
  from_port                = var.elasticache_port
  to_port                  = var.elasticache_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow Redis from application tasks"
}

resource "aws_security_group_rule" "elasticache_egress_to_vpc" {
  security_group_id = aws_security_group.elasticache.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic within VPC"
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "vpc_endpoints_ingress_from_app" {
  security_group_id        = aws_security_group.vpc_endpoints.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  description              = "Allow HTTPS from application tasks to VPC endpoints"
}

resource "aws_security_group_rule" "vpc_endpoints_egress_to_vpc" {
  security_group_id = aws_security_group.vpc_endpoints.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow all traffic within VPC"
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-db-subnet-group-"
  subnet_ids  = aws_subnet.db[*].id
  description = "DB subnet group for ${var.project_name}-${var.environment} RDS"
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-cache-subnet-group"
  subnet_ids = aws_subnet.db[*].id
  description = "ElastiCache subnet group for ${var.project_name}-${var.environment} Redis"
  tags       = var.tags
}

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/${var.project_name}/vpc/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_flow_log" "main" {
  iam_role_arn         = aws_iam_role.flow_logs.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

# CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days
  kms_key_id = aws_kms_key.logs.arn # CloudTrail logs to this log group, so use the logs KMS key
  tags              = var.tags
}

resource "aws_sns_topic" "cloudtrail_notifications" {
  name              = "${var.project_name}-${var.environment}-cloudtrail-notifications"
  kms_master_key_id = aws_kms_key.sns.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "cloudtrail_notifications" {
  arn = aws_sns_topic.cloudtrail_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudTrailPublish"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.cloudtrail_notifications.arn
    }]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "cloudtrail"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  sns_topic_name                = aws_sns_topic.cloudtrail_notifications.name
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  tags                          = var.tags
}

# CloudWatch Metric Filters and Alarms for CloudTrail
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
  alarm_actions       = [aws_sns_topic.cloudtrail_notifications.arn]
  ok_actions          = [aws_sns_topic.cloudtrail_notifications.arn]
  treat_missing_data  = "notBreaching"
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
  alarm_actions       = [aws_sns_topic.cloudtrail_notifications.arn]
  ok_actions          = [aws_sns_topic.cloudtrail_notifications.arn]
  treat_missing_data  = "notBreaching"
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
  alarm_actions       = [aws_sns_topic.cloudtrail_notifications.arn]
  ok_actions          = [aws_sns_topic.cloudtrail_notifications.arn]
  treat_missing_data  = "notBreaching"
  tags                = var.tags
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

resource "aws_securityhub_standards_subscription" "aws_foundational_security_best_practices" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# AWS Config
resource "aws_cloudwatch_log_group" "config" {
  name              = "/aws/config/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days
  kms_key_id = aws_kms_key.logs.arn # Config logs to this log group, so use the logs KMS key
  tags              = var.tags
}

resource "aws_sns_topic" "config_notifications" {
  name              = "${var.project_name}-${var.environment}-config-notifications"
  kms_master_key_id = aws_kms_key.sns.arn
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowConfigPublish"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config_notifications.arn
    }]
  })
}

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported             = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name              = "${var.project_name}-${var.environment}-delivery-channel"
  s3_bucket_name    = aws_s3_bucket.config_logs.id
  sns_topic_arn     = aws_sns_topic.config_notifications.arn
  s3_key_prefix     = "config"
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "${var.project_name}-${var.environment}-s3-public-read-prohibited"
  description = "Checks that your Amazon S3 buckets do not allow public read access."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "${var.project_name}-${var.environment}-rds-storage-encrypted"
  description = "Checks whether the Amazon RDS DB instance is encrypted at rest."
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "${var.project_name}-${var.environment}-iam-root-access-key-check"
  description = "Checks whether the root user has an access key."
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "${var.project_name}-${var.environment}-encrypted-volumes"
  description = "Checks whether Amazon EBS volumes that are attached to Amazon EC2 instances are encrypted."
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "${var.project_name}-${var.environment}-multi-region-cloudtrail-enabled"
  description = "Checks whether AWS CloudTrail is enabled in all regions."
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private[*].id, aws_route_table.db[*].id)
  tags              = var.tags
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  private_dns_enabled = true
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  tags               = var.tags
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


resource "aws_s3_bucket_logging" "config_logs_logging" {
  bucket        = aws_s3_bucket.config_logs.id
  target_bucket = aws_s3_bucket.config_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "alb_logs_logging" {
  bucket        = aws_s3_bucket.alb_logs.id
  target_bucket = aws_s3_bucket.alb_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_versioning" "cloudtrail_logs_access_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_versioning" "alb_logs_versioning" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_logging" "cloudtrail_logs_access_logging" {
  bucket        = aws_s3_bucket.cloudtrail_logs_access.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}
