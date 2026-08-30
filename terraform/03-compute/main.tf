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

data "aws_acm_certificate" "main" {
  domain   = var.certificate_domain_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  ecs_service_name = "${var.project_name}-${var.environment}-app"
}

# KMS Key for S3 ALB Logs (RULE 17, 22, 29, 58)
resource "aws_kms_key" "s3_alb_logs" {
  description             = "${var.project_name}-${var.environment}-alb-logs-cmk"
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
      }
    ]
  })
  tags = var.tags
}

resource "random_id" "kms_s3_alb_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "s3_alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-alb-logs-${random_id.kms_s3_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.s3_alb_logs.key_id
}

# KMS Key for CloudWatch Logs (RULE 17, 22, 27, 29, 58)
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
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}" # RULE 27, 29
  target_key_id = aws_kms_key.logs.key_id
}

# S3 Bucket for ALB Access Logs (RULE 18, 23, 26, 30)
resource "aws_s3_bucket" "alb_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-alb-logs-" # RULE 26, 58
  force_destroy = false                                               # RULE 30
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
    status = "Disabled" # Log buckets typically don't need versioning
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

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}
    expiration {
      days = 90 # Retain ALB logs for 90 days
    }
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [data.terraform_remote_state.networking.outputs.alb_security_group_id]
  subnets                    = data.terraform_remote_state.networking.outputs.public_subnet_ids
  enable_deletion_protection = true # RULE 46
  drop_invalid_header_fields = true # RULE 46
  tags                       = var.tags

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb"
    enabled = true
  }
}

resource "aws_lb_target_group" "ecs_app" {
  name        = "${var.project_name}-${var.environment}-ecs-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
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
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # MANDATORY AWS SECURITY RULE
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_app.arn
    type             = "forward"
  }
}

# ALB Security Group Rules (using remote state SG ID)
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # RULE 8b
  security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description       = "Allow HTTP from internet for redirect" # RULE 51
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # RULE 8b
  security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description       = "Allow HTTPS from internet" # RULE 51
}

resource "aws_security_group_rule" "alb_egress_ecs" {
  type                     = "egress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.alb_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description              = "Allow outbound to ECS App Service" # RULE 51
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.tags
}

# ECS Task Execution Role (RULE 26, 58)
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix        = "${var.project_name}-${var.environment}-ecs-exec-" # RULE 26, 58
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
    create_before_destroy = true # RULE 26
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (Application Permissions) (RULE 26, 58)
resource "aws_iam_role" "ecs_task" {
  name_prefix        = "${var.project_name}-${var.environment}-ecs-task-" # RULE 26, 58
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
    create_before_destroy = true # RULE 26
  }
}

# Policy for ECS Task Role to access Secrets Manager
resource "aws_iam_role_policy" "ecs_task_secrets_access" {
  name = "${var.project_name}-${var.environment}-ecs-task-secrets-access"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = data.terraform_remote_state.data.outputs.db_secret_arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = data.terraform_remote_state.data.outputs.kms_rds_key_arn
      }
    ]
  })
}

# CloudWatch Log Group for ECS Service (RULE 39)
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.project_name}/${var.environment}/${local.ecs_service_name}"
  retention_in_days = var.log_retention_days # RULE 39
  kms_key_id        = aws_kms_key.logs.arn   # RULE 39
  tags              = var.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app-task"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  tags                     = var.tags

  container_definitions = jsonencode([
    {
      name        = "app"
      image       = var.app_image
      cpu         = var.ecs_task_cpu
      memory      = var.ecs_task_memory
      essential   = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
      environment = [
        { name = "DB_ENDPOINT", value = data.terraform_remote_state.data.outputs.db_endpoint },
        { name = "DB_PORT", value = tostring(data.terraform_remote_state.data.outputs.db_port) },
        { name = "DB_NAME", value = data.terraform_remote_state.data.outputs.db_name },
        { name = "REDIS_ENDPOINT", value = data.terraform_remote_state.data.outputs.redis_primary_endpoint },
        { name = "REDIS_PORT", value = tostring(data.terraform_remote_state.data.outputs.redis_port) }
      ]
      secrets = [
        {
          name      = "DB_CREDENTIALS"
          valueFrom = data.terraform_remote_state.data.outputs.db_secret_arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_app.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = local.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_desired_count
  platform_version = "1.4.0" # Latest Fargate platform version

  network_configuration {
    subnets          = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.networking.outputs.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_app.arn
    container_name   = "app"
    container_port   = var.app_port
  }

  tags = var.tags
}

# ECS App Security Group Rules (using remote state SG ID)
resource "aws_security_group_rule" "ecs_ingress_alb" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.networking.outputs.alb_security_group_id
  description              = "Allow inbound from ALB" # RULE 51
}

resource "aws_security_group_rule" "ecs_egress_db" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.db_port
  to_port                  = data.terraform_remote_state.data.outputs.db_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.data.outputs.db_security_group_id
  description              = "Allow outbound to RDS Database" # RULE 51
}

resource "aws_security_group_rule" "ecs_egress_elasticache" {
  type                     = "egress"
  from_port                = data.terraform_remote_state.data.outputs.redis_port
  to_port                  = data.terraform_remote_state.data.outputs.redis_port
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.networking.outputs.app_security_group_id
  source_security_group_id = data.terraform_remote_state.data.outputs.elasticache_security_group_id
  description              = "Allow outbound to ElastiCache Redis" # RULE 51
}

resource "aws_security_group_rule" "ecs_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.terraform_remote_state.networking.outputs.vpc_cidr_block] # RULE 8
  security_group_id = data.terraform_remote_state.networking.outputs.app_security_group_id
  description       = "Allow all outbound within VPC (via NAT Gateway)" # RULE 51
}

# ECS Service Auto Scaling (RULE 35)
resource "aws_appautoscaling_target" "ecs_app_cpu" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_desired_count
  max_capacity       = var.ecs_max_count
}

resource "aws_appautoscaling_policy" "ecs_app_cpu" {
  name               = "${local.ecs_service_name}-cpu-scaling-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_app_cpu.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_app_cpu.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# CloudWatch Alarms (RULE 35)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.logs.arn # RULE 45
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

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
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
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.ecs_app.arn_suffix
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
    DBInstanceIdentifier = data.terraform_remote_state.data.outputs.rds_cluster_id # For Aurora, this is the cluster ID
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
  threshold           = var.rds_free_storage_threshold_bytes # e.g., 20% of 100GB = 20GB = 20 * 1024^3 bytes
  alarm_description   = "RDS free storage space is too low"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.data.outputs.rds_cluster_id
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
