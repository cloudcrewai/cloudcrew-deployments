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

data "aws_route53_zone" "selected" {
  name         = var.route53_zone_name
  private_zone = false
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
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

resource "random_id" "kms_s3_alb_logs_suffix" {
  byte_length = 4
}

resource "random_id" "kms_cloudwatch_logs_suffix" {
  byte_length = 4
}

# KMS Key for S3 ALB Logs (RULE 17, RULE 29)
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
        Sid    = "AllowS3Service"
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

resource "aws_kms_alias" "s3_alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-s3-alb-logs-${random_id.kms_s3_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.s3_alb_logs.key_id
}

# KMS Key for CloudWatch Logs (RULE 17, RULE 22, RULE 29)
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "${var.project_name}-${var.environment}-cloudwatch-logs-cmk"
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

# IAM Role for ECS Task Execution (RULE 26, RULE 58)
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix        = "${var.project_name}-${var.environment}-ecs-exec-"
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

# IAM Role for ECS Task (RULE 26, RULE 58)
resource "aws_iam_role" "ecs_task" {
  name_prefix        = "${var.project_name}-${var.environment}-ecs-task-"
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

resource "aws_iam_policy" "ecs_task_policy" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-task-policy-"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = data.terraform_remote_state.data.outputs.db_secret_arn
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = data.terraform_remote_state.data.outputs.s3_bucket_arn
      }
    ]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# ECR Repository (RULE 47)
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

# S3 Bucket Policy for ALB Access Logs (RULE 18)
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

# ACM Certificate (RULE 37)
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = [
    "${var.subdomain_name}.${var.domain_name}"
  ]
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
      zone_id = data.aws_route53_zone.selected.zone_id
    }
  }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# ALB (RULE 46)
resource "aws_lb" "main" {
  name                       = var.alb_name
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
  name     = var.alb_target_group_name
  port     = var.ecs_container_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = var.alb_health_check_path
    port                = var.alb_health_check_port
    protocol            = "HTTP"
    interval            = var.alb_health_check_interval
    timeout             = var.alb_health_check_timeout
    healthy_threshold   = var.alb_health_check_healthy_threshold
    unhealthy_threshold = var.alb_health_check_unhealthy_threshold
    matcher             = var.alb_health_check_matcher
  }
  tags = var.tags
}

# ALB HTTP Listener (redirect to HTTPS)
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

# ALB HTTPS Listener (MANDATORY SECURITY RULE)
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

# Security Group Rules for ALB (RULE 8b, RULE 51)
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

resource "aws_security_group_rule" "alb_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description       = "Allow all outbound traffic within VPC"
}

# Security Group Rules for App (ECS) (RULE 8, RULE 51)
resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow traffic from ALB to ECS containers"
}

resource "aws_security_group_rule" "app_egress_to_db" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.db_port
  to_port                  = data.terraform_remote_state.data.outputs.db_port
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.networking.outputs.db_security_group_id
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow outbound to RDS database"
}

resource "aws_security_group_rule" "app_egress_to_redis" {
  type              = "egress"
  from_port         = data.terraform_remote_state.data.outputs.redis_port
  to_port           = data.terraform_remote_state.data.outputs.redis_port
  protocol          = "tcp"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow outbound to ElastiCache Redis within VPC"
}

resource "aws_security_group_rule" "app_egress_vpc_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block]
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow all outbound traffic within VPC"
}

# CloudWatch Log Group for ECS Service (RULE 39)
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.project_name}/${var.environment}/${var.ecs_service_name}"
  retention_in_days = var.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# ECS Cluster (RULE 39)
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

# ECS Task Definition (RULE 39)
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-${var.ecs_service_name}"
  cpu                      = tostring(var.ecs_cpu * 1024)    # Convert vCPU to CPU units
  memory                   = tostring(var.ecs_memory * 1024) # Convert GB to MiB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.ecs_service_name
      image     = var.ecs_container_image
      cpu       = var.ecs_cpu * 1024
      memory    = var.ecs_memory * 1024
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
        }
      ]
      environment = [
        {
          name  = "DB_ENDPOINT"
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
          name  = "REDIS_ENDPOINT"
          value = data.terraform_remote_state.data.outputs.redis_primary_endpoint
        },
        {
          name  = "REDIS_PORT"
          value = tostring(data.terraform_remote_state.data.outputs.redis_port)
        }
      ]
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = data.terraform_remote_state.data.outputs.db_secret_arn
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
    }
  ])
  tags = var.tags
}

# ECS Service (RULE 39)
resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
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
    container_name   = var.ecs_service_name
    container_port   = var.ecs_container_port
  }

  tags = var.tags
}

# ECS Service Auto Scaling (RULE 35)
resource "aws_appautoscaling_target" "ecs_cpu" {
  max_capacity       = var.ecs_desired_count * 2
  min_capacity       = var.ecs_desired_count
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
    target_value = var.ecs_cpu_utilization_threshold
  }
}

# CloudWatch Alarms (RULE 35)
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_error_threshold
  alarm_description   = "ALB 5XX errors are too high"
  actions_enabled     = true
  alarm_actions       = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]

  dimensions = {
    LoadBalancer = aws_lb.main.id
    TargetGroup  = aws_lb_target_group.app.id
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
  threshold           = var.ecs_cpu_utilization_threshold
  alarm_description   = "ECS service CPU utilization is too high"
  actions_enabled     = true
  alarm_actions       = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]
  ok_actions          = [data.terraform_remote_state.data.outputs.alarms_sns_topic_arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}
