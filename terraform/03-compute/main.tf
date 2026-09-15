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
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
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
  container_definitions = jsonencode([
    {
      name        = "${var.project_name}-${var.environment}-app"
      image       = "${aws_ecr_repository.app.repository_url}:latest"
      cpu         = var.ecs_task_cpu
      memory      = var.ecs_task_memory
      essential   = true
      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        { name = "DB_ENDPOINT", value = data.terraform_remote_state.data.outputs.db_endpoint },
        { name = "DB_PORT", value = tostring(data.terraform_remote_state.data.outputs.db_port) },
        { name = "DB_NAME", value = data.terraform_remote_state.data.outputs.db_name },
        { name = "REDIS_ENDPOINT", value = data.terraform_remote_state.data.outputs.redis_primary_endpoint },
        { name = "REDIS_PORT", value = tostring(data.terraform_remote_state.data.outputs.redis_port) },
        { name = "S3_ASSETS_BUCKET", value = data.terraform_remote_state.data.outputs.s3_bucket_id }
      ]
      secrets = [
        {
          name      = "DB_CREDENTIALS"
          valueFrom = aws_secretsmanager_secret.db_credentials.arn
        }
      ]
    }
  ])
}

# KMS Keys (from blueprint components)
resource "aws_kms_key" "rds" {
  description             = var.rds_kms_key_description
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
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "elasticache" {
  description             = var.elasticache_kms_key_description
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
}

resource "random_id" "kms_elasticache_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "elasticache" {
  name          = "alias/${var.project_name}-${var.environment}-elasticache-${random_id.kms_elasticache_suffix.hex}"
  target_key_id = aws_kms_key.elasticache.key_id
}

resource "aws_kms_key" "s3_alb_logs" {
  description             = var.s3_alb_logs_kms_key_description
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

resource "random_id" "kms_s3_alb_logs_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "s3_alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-s3-alb-logs-${random_id.kms_s3_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.s3_alb_logs.key_id
}

resource "aws_kms_key" "secrets_manager" {
  description             = var.secrets_manager_kms_key_description
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
        Sid    = "AllowSecretsManagerUseOfKey"
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
}

resource "random_id" "kms_secrets_manager_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "secrets_manager" {
  name          = "alias/${var.project_name}-${var.environment}-secrets-manager-${random_id.kms_secrets_manager_suffix.hex}"
  target_key_id = aws_kms_key.secrets_manager.key_id
}

resource "aws_kms_key" "logs" {
  description             = var.cloudwatch_logs_kms_key_description
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

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# S3 Bucket for ALB Access Logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-${var.environment}-alb-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
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

# Route53 and ACM
resource "aws_route53_zone" "main" {
  name = var.route53_hosted_zone
  tags = var.tags
}

resource "aws_acm_certificate" "main" {
  domain_name       = var.acm_domain
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# WAF
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-${var.environment}-waf"
  scope = var.waf_scope

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
      metric_name                = "${var.project_name}-bad-inputs-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 3

    action {
      block {}
    }

    statement {
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit"
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

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

# ALB
resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = var.alb_scheme == "internal"
  load_balancer_type         = "application"
  security_groups            = [data.terraform_remote_state.networking.outputs.alb_security_group_id]
  subnets                    = data.terraform_remote_state.networking.outputs.public_subnet_ids
  enable_deletion_protection = var.alb_enable_deletion_protection
  drop_invalid_header_fields = var.alb_drop_invalid_header_fields
  tags                       = var.tags

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb"
    enabled = true
  }
}

resource "aws_route53_record" "alb_dns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.acm_domain
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "ecs_app" {
  name        = "${var.project_name}-${var.environment}-ecs-app-tg"
  port        = var.ecs_container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
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
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_app.arn
    type             = "forward"
  }
}

# ECR
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = var.ecr_image_tag_mutability

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

# ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "prod-three-ti-ecs-task-execution-role-"
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name_prefix = "prod-three-tier-web-pro-ecs-task-role-"
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

resource "aws_iam_role_policy" "ecs_task_s3" {
  name = "${var.project_name}-${var.environment}-ecs-task-s3-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Effect   = "Allow"
      Resource = [
        data.terraform_remote_state.data.outputs.s3_bucket_arn,
        "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_secrets_manager" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-manager-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.db_credentials.arn
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_kms" {
  name = "${var.project_name}-${var.environment}-ecs-task-kms-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
      Effect   = "Allow"
      Resource = aws_kms_key.secrets_manager.arn
    }]
  })
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app-task"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  container_definitions    = local.container_definitions
  tags                     = var.tags
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.project_name}/${var.environment}/app"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_desired_count
  tags            = var.tags

  network_configuration {
    subnets          = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.networking.outputs.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_app.arn
    container_name   = "${var.project_name}-${var.environment}-app"
    container_port   = var.ecs_container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_cpu" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name              = "${var.project_name}-${var.environment}-ecs-cpu-scaling-policy"
  policy_type       = "TargetTrackingScaling"
  resource_id       = aws_appautoscaling_target.ecs_cpu.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_cpu.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_cpu.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.ecs_cpu_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_target" "ecs_memory" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name              = "${var.project_name}-${var.environment}-ecs-memory-scaling-policy"
  policy_type       = "TargetTrackingScaling"
  resource_id       = aws_appautoscaling_target.ecs_memory.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_memory.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_memory.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.ecs_memory_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-db-credentials-"
  kms_key_id              = aws_kms_key.secrets_manager.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "secrets_rotation" {
  name_prefix = "prod-three-tier-secrets-rotation-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "secrets_rotation_lambda_basic_execution" {
  role       = aws_iam_role.secrets_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "secrets_rotation_secrets_manager" {
  name = "${var.project_name}-${var.environment}-secrets-rotation-sm-policy"
  role = aws_iam_role.secrets_rotation.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_credentials.arn
      },
      {
        Action   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"]
        Effect   = "Allow"
        Resource = aws_kms_key.secrets_manager.arn
      }
    ]
  })
}

data "archive_file" "secrets_rotation" {
  type = "zip"
  source_content = <<-PY
    import json
    def lambda_handler(event, context):
        # This is a placeholder Lambda function for Secrets Manager rotation.
        # In a real scenario, this function would contain logic to rotate the database credentials.
        # For example, it would connect to the database, change the password, and update the secret.
        print("Secrets Manager rotation Lambda invoked.")
        print(f"Event: {json.dumps(event)}")
        # Implement actual rotation logic here
        return {"statusCode": 200, "body": json.dumps("Rotation placeholder executed successfully!")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/secrets_rotation.zip"
}

resource "aws_lambda_function" "secrets_rotation" {
  function_name    = "${var.project_name}-${var.environment}-secrets-rotation"
  role             = aws_iam_role.secrets_rotation.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.secrets_rotation.output_path
  source_code_hash = data.archive_file.secrets_rotation.output_base64sha256
  timeout          = 300 # 5 minutes
  memory_size      = 128 # Minimum memory
  tags             = var.tags

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }
}

resource "aws_secretsmanager_secret_rotation" "db_credentials" {
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# CloudWatch Dashboard and Alarms
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-app-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS Service CPU and Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.name, "TargetGroup", aws_lb_target_group.ecs_app.name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
          title  = "ALB 5XX Errors"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-alarm"
  comparison_operator = var.ecs_cpu_alarm_comparison_operator
  evaluation_periods  = 2
  metric_name         = var.ecs_cpu_alarm_metric_name
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_cpu_alarm_threshold
  alarm_description   = "This alarm monitors ECS service CPU utilization"
  alarm_actions       = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-alarm"
  comparison_operator = var.ecs_memory_alarm_comparison_operator
  evaluation_periods  = 2
  metric_name         = var.ecs_memory_alarm_metric_name
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_memory_alarm_threshold
  alarm_description   = "This alarm monitors ECS service Memory utilization"
  alarm_actions       = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

# Security Group Rules (using remote state security group IDs)
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
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.alb_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow ALB to ECS app"
}

resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description              = "Allow ECS app from ALB"
}

resource "aws_security_group_rule" "ecs_egress_to_rds" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.db_port
  to_port                  = data.terraform_remote_state.data.outputs.db_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.db_security_group_id
  description              = "Allow ECS app to RDS"
}

resource "aws_security_group_rule" "ecs_egress_to_elasticache" {
  type        = "egress"
  from_port   = data.terraform_remote_state.data.outputs.redis_port
  to_port     = data.terraform_remote_state.data.outputs.redis_port
  protocol    = "tcp"
  cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description = "Allow ECS app to ElastiCache"
}

resource "aws_security_group_rule" "ecs_egress_to_vpc_cidr" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description = "Allow all traffic within VPC for ECS"
}

resource "aws_security_group_rule" "secrets_rotation_lambda_egress_to_secrets_manager" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description = "Allow Secrets Rotation Lambda to Secrets Manager"
}

resource "aws_cloudwatch_log_group" "waf_main" {
  name              = "aws-waf-logs-main"
  retention_in_days = 90
}
