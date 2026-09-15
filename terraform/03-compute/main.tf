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
}

#
# IAM Roles and Policies
#

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
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
      Action   = [
        "s3:GetObject",
        "s3:PutObject",
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

resource "aws_iam_role_policy" "ecs_task_secrets_manager" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = data.terraform_remote_state.data.outputs.db_credentials_secret_id
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_rds" {
  name = "${var.project_name}-${var.environment}-ecs-task-rds-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "rds-db:connect"
      ]
      Effect   = "Allow"
      Resource = data.terraform_remote_state.data.outputs.rds_instance_arn
    }]
  })
}

resource "aws_iam_role_policy" "ecs_task_elasticache" {
  name = "${var.project_name}-${var.environment}-ecs-task-elasticache-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "elasticache:Connect"
      ]
      Effect   = "Allow"
      Resource = data.terraform_remote_state.data.outputs.elasticache_replication_group_arn
    }]
  })
}

resource "aws_iam_role" "lambda_rotation" {
  name_prefix = "prod-three-tier-lambda-rotation-role-"
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

resource "aws_iam_role_policy_attachment" "lambda_rotation_basic_execution" {
  role       = aws_iam_role.lambda_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_rotation_secrets_manager" {
  name = "${var.project_name}-${var.environment}-lambda-rotation-secrets-policy"
  role = aws_iam_role.lambda_rotation.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ]
      Effect   = "Allow"
      Resource = data.terraform_remote_state.data.outputs.db_credentials_secret_id
    }]
  })
}

#
# ECR Repository
#

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

#
# Secrets Manager Rotation Lambda
#

data "archive_file" "rotation" {
  type = "zip"
  source_content = <<-PY
    import json
    def lambda_handler(event, context):
        # Placeholder for actual secret rotation logic
        # In a real scenario, this would connect to the database,
        # generate a new password, update the secret, and then
        # update the database with the new password.
        print(f"Rotating secret: {event.get('SecretId')}")
        return {"statusCode": 200, "body": json.dumps("rotation placeholder")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/rotation.zip"
}

resource "aws_lambda_function" "rotation" {
  function_name    = "${var.project_name}-${var.environment}-rotation"
  role             = aws_iam_role.lambda_rotation.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.rotation.output_path
  source_code_hash = data.archive_file.rotation.output_base64sha256

  tracing_config {
    mode = "Active"
  }
  tags = var.tags
}

resource "aws_secretsmanager_secret_rotation" "db_credentials" {
  secret_id           = data.terraform_remote_state.data.outputs.db_credentials_secret_id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

#
# ACM Certificate (for ALB HTTPS)
#

resource "aws_acm_certificate" "main" {
  domain_name       = var.acm_domain_name
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "main" {
  name         = var.route53_hosted_zone
  private_zone = false
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

#
# ALB and Target Group
#

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

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-tg"
  port        = var.ecs_container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = var.tags
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
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

#
# WAFv2
#

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
      metric_name                = "${var.project_name}-bad-inputs-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit-rule"
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
  kms_key_id        = data.terraform_remote_state.data.outputs.kms_logs_key_arn
  tags              = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

#
# ECS Cluster, Task Definition, Service
#

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
  kms_key_id        = data.terraform_remote_state.data.outputs.kms_logs_key_arn
  tags              = var.tags
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app-task"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name        = "app"
      image       = "${aws_ecr_repository.app.repository_url}:latest"
      cpu         = var.ecs_task_cpu
      memory      = var.ecs_task_memory
      essential   = true
      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = data.terraform_remote_state.data.outputs.db_endpoint
        },
        {
          name  = "DB_PORT"
          value = tostring(data.terraform_remote_state.data.outputs.db_port)
        },
        {
          name  = "DB_NAME"
          value = data.terraform_remote_state.data.outputs.db_name
        },
        {
          name  = "REDIS_HOST"
          value = data.terraform_remote_state.data.outputs.redis_primary_endpoint
        },
        {
          name  = "REDIS_PORT"
          value = tostring(data.terraform_remote_state.data.outputs.redis_port)
        }
      ]
      secrets = [
        {
          name      = "DB_CREDENTIALS"
          valueFrom = data.terraform_remote_state.data.outputs.db_credentials_secret_id
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_service.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = var.tags
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_desired_count

  network_configuration {
    subnets          = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.networking.outputs.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.ecs_container_port
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  tags                    = var.tags
}

resource "aws_appautoscaling_target" "ecs_cpu" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_min_capacity
  max_capacity       = var.ecs_max_capacity
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.project_name}-${var.environment}-ecs-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_cpu.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_cpu.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.ecs_cpu_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_target" "ecs_memory" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_min_capacity
  max_capacity       = var.ecs_max_capacity
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.project_name}-${var.environment}-ecs-memory-scaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_memory.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_memory.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.ecs_memory_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

#
# CloudWatch Alarms
#

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-utilization"
  comparison_operator = var.ecs_cpu_alarm_comparison_operator
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_cpu_alarm_threshold
  alarm_description   = "Average CPU utilization for ECS service exceeds ${var.ecs_cpu_alarm_threshold}%"
  actions_enabled     = true
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-utilization"
  comparison_operator = var.ecs_memory_alarm_comparison_operator
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_memory_alarm_threshold
  alarm_description   = "Average Memory utilization for ECS service exceeds ${var.ecs_memory_alarm_threshold}%"
  actions_enabled     = true
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

#
# Route53 Application DNS
#

resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.app_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudwatch_log_group" "waf_main" {
  name              = "aws-waf-logs-main"
  retention_in_days = 90
}
