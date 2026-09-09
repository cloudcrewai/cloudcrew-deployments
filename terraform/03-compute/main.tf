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

data "aws_acm_certificate" "main" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
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
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs"
  target_key_id = aws_kms_key.logs.key_id
}

resource "random_id" "kms_s3_assets_suffix" {
  byte_length = 4
}

resource "random_id" "kms_alb_logs_suffix" {
  byte_length = 4
}

resource "random_id" "kms_cloudwatch_logs_suffix" {
  byte_length = 4
}

resource "random_id" "kms_secrets_manager_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  ecs_task_cpu    = 1024 # 1 vCPU
  ecs_task_memory = 2048 # 2 GB
  app_port        = 8080 # Default application port
}

# KMS Key for S3 application assets (kms_s3_encryption)
resource "aws_kms_key" "s3_assets" {
  description             = "KMS key for S3 application assets"
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
        Sid    = "AllowS3ServiceAccess"
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
  tags = var.tags
}

resource "aws_kms_alias" "s3_assets" {
  name          = "alias/${var.project_name}-${var.environment}-s3-assets-${random_id.kms_s3_assets_suffix.hex}"
  target_key_id = aws_kms_key.s3_assets.key_id
}

# KMS Key for ALB access logs (kms_alb_logs_encryption)
resource "aws_kms_key" "alb_logs" {
  description             = "KMS key for ALB access logs"
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
        Sid    = "AllowALBServiceAccess"
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

resource "aws_kms_alias" "alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-alb-logs-${random_id.kms_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.alb_logs.key_id
}

# KMS Key for CloudWatch Logs encryption (kms_cloudwatch_logs_encryption)
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for CloudWatch Logs encryption"
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
  name          = "alias/${var.project_name}-${var.environment}-cloudwatch-logs-${random_id.kms_cloudwatch_logs_suffix.hex}"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

# KMS Key for Secrets Manager (secrets_manager)
resource "aws_kms_key" "secrets_manager" {
  description             = "KMS key for Secrets Manager"
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
        Sid    = "AllowSecretsManagerServiceAccess"
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

resource "aws_kms_alias" "secrets_manager" {
  name          = "alias/${var.project_name}-${var.environment}-secrets-manager-${random_id.kms_secrets_manager_suffix.hex}"
  target_key_id = aws_kms_key.secrets_manager.key_id
}

# Secrets Manager (secrets_manager)
resource "aws_secretsmanager_secret" "app_secrets" {
  name_prefix             = "${var.project_name}-${var.environment}-app-secrets-"
  description             = "Database credentials and application secrets"
  kms_key_id              = aws_kms_key.secrets_manager.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "app_secrets" {
  secret_arn = aws_secretsmanager_secret.app_secrets.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableAccessForECS"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.ecs_task.arn }
        Action    = "secretsmanager:GetSecretValue"
        Resource  = aws_secretsmanager_secret.app_secrets.arn
      },
      {
        Sid       = "EnableAccessForRoot"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "secretsmanager:*"
        Resource  = "*"
      }
    ]
  })
}

# ECR Repository (ecr_repo)
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remove untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}

# IAM Roles
resource "aws_iam_role" "ecs_task" {
  name_prefix = "three-tier-web-app-prod-ecs-task-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "ecs_task_s3_access" {
  name = "${var.project_name}-${var.environment}-ecs-task-s3-access"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Effect   = "Allow"
      Resource = [
        data.terraform_remote_state.data.outputs.s3_bucket_arn,
        "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_secrets_manager_access" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-manager-access"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.app_secrets.arn
    }]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "three-tier-we-ecs-task-execution-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "alb_logs" {
  name_prefix = "three-tier-web-app-prod-alb-logs-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "elasticloadbalancing.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "cloudwatch_alarms_sns" {
  name_prefix = "three-tier-web-app-pr-alarms-sns-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description       = "Allow HTTP from internet for redirect"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description       = "Allow HTTPS from internet"
}

resource "aws_security_group_rule" "alb_egress_to_ecs" {
  type                     = "egress"
  from_port                = local.app_port
  to_port                  = local.app_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.alb_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow outbound to ECS tasks"
}

resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = local.app_port
  to_port                  = local.app_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description              = "Allow inbound from ALB"
}

resource "aws_security_group_rule" "ecs_egress_to_db" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.db_port
  to_port                  = data.terraform_remote_state.data.outputs.db_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.db_security_group_id
  description              = "Allow outbound to RDS PostgreSQL"
}

resource "aws_security_group_rule" "ecs_egress_to_elasticache" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.redis_port
  to_port                  = data.terraform_remote_state.data.outputs.redis_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.data.outputs.elasticache_security_group_id
  description              = "Allow outbound to ElastiCache Redis"
}

resource "aws_security_group_rule" "ecs_egress_to_s3" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to S3 via VPC endpoint or NAT"
}

resource "aws_security_group_rule" "ecs_egress_to_secrets_manager" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to Secrets Manager via VPC endpoint or NAT"
}

resource "aws_security_group_rule" "ecs_egress_to_ecr" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to ECR via VPC endpoint or NAT"
}

resource "aws_security_group_rule" "ecs_egress_to_cloudwatch_logs" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to CloudWatch Logs via VPC endpoint or NAT"
}

resource "aws_security_group_rule" "ecs_egress_to_kms" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to KMS via VPC endpoint or NAT"
}

# ALB (alb)
resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [data.terraform_remote_state.networking.outputs.alb_security_group_id]
  subnets                    = data.terraform_remote_state.networking.outputs.public_subnet_ids
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
    enabled = true
  }
  tags = var.tags
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-tg"
  port        = local.app_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = var.tags
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowALBLogging"
      Effect = "Allow"
      Principal = {
        Service = "elasticloadbalancing.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${data.terraform_remote_state.data.outputs.alb_logs_bucket_arn}/*"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.alb_logs.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = data.terraform_remote_state.data.outputs.alb_logs_bucket_id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# WAF (waf)
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-${var.environment}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-known-bad-inputs-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }
  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

# ECS (ecs_service)
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_service" {
  name              = "/ecs/${var.project_name}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app-task"
  cpu                      = local.ecs_task_cpu
  memory                   = local.ecs_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = aws_ecr_repository.app.repository_url
      portMappings = [
        {
          containerPort = local.app_port
          hostPort      = local.app_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DB_ENDPOINT", value = data.terraform_remote_state.data.outputs.db_endpoint },
        { name = "DB_PORT", value = tostring(data.terraform_remote_state.data.outputs.db_port) },
        { name = "DB_NAME", value = data.terraform_remote_state.data.outputs.db_name },
        { name = "REDIS_ENDPOINT", value = data.terraform_remote_state.data.outputs.redis_primary_endpoint },
        { name = "REDIS_PORT", value = tostring(data.terraform_remote_state.data.outputs.redis_port) },
        { name = "S3_BUCKET_NAME", value = data.terraform_remote_state.data.outputs.s3_bucket_id }
      ]
      secrets = [
        { name = "DB_CREDENTIALS", valueFrom = data.terraform_remote_state.data.outputs.db_secret_arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      essential = true
    }
  ])
  tags = var.tags
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 4

  network_configuration {
    subnets          = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.networking.outputs.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = local.app_port
  }

  depends_on = [
    aws_lb_listener.https,
    aws_lb_listener.http_redirect
  ]
  tags = var.tags
}

resource "aws_appautoscaling_target" "ecs_cpu" {
  max_capacity       = 8
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.project_name}-${var.environment}-ecs-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_cpu.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_cpu.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_cpu.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 75
  }
}

# CloudWatch Alarms & SNS (cloudwatch)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.secrets_manager.arn # Using secrets manager KMS key for SNS
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

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "ALB 5xx error rate is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = aws_lb.main.arn
    TargetGroup  = aws_lb_target_group.app.arn
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS service CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.data.outputs.rds_instance_identifier
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
  alarm_description   = "RDS free storage space is low"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.data.outputs.rds_instance_identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-elasticache-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ElastiCache CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    ReplicationGroup = data.terraform_remote_state.data.outputs.elasticache_replication_group_id
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "waf_main" {
  name              = "aws-waf-logs-main"
  retention_in_days = 90
}
