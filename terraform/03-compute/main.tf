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

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_acm_certificate" "main" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

data "aws_s3_bucket" "alb_logs" {
  bucket = data.terraform_remote_state.data.outputs.s3_alb_logs_bucket_id
}

data "aws_route53_zone" "public" {
  name         = var.domain_name
  private_zone = false
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for EBS (RULE 28)
resource "aws_kms_key" "ebs" {
  description             = "${var.project_name}-${var.environment}-ebs-cmk"
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
        Sid    = "AllowServiceLinkedRoleUseOfKey"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
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
        Sid    = "AllowAttachmentOfPersistentResources"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action   = "kms:CreateGrant"
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "random_id" "kms_ebs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project_name}-${var.environment}-ebs-${random_id.kms_ebs_suffix.hex}"
  target_key_id = aws_kms_key.ebs.key_id
}

# KMS Key for Secrets Manager (RULE 15, RULE 49)
resource "aws_kms_key" "secrets_manager" {
  description             = "${var.project_name}-${var.environment}-secrets-manager-cmk"
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
        Sid    = "AllowSecretsManager"
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

# ECR Repository (RULE 47)
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = true
  }
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

# Application Load Balancer (RULE 46, RULE 18)
resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [data.terraform_remote_state.networking.outputs.alb_security_group_id]
  subnets                    = data.terraform_remote_state.networking.outputs.public_subnet_ids
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  tags                       = var.tags

  access_logs {
    bucket  = data.terraform_remote_state.data.outputs.s3_alb_logs_bucket_id
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = data.aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowALBLogging"
      Effect = "Allow"
      Principal = {
        Service = "elasticloadbalancing.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${data.aws_s3_bucket.alb_logs.arn}/*"
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
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    enabled             = true
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
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Cluster and Service
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name_prefix        = "three-tier-web-app-productio-ecs-exec-"
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

resource "aws_iam_role" "ecs_task" {
  name_prefix        = "three-tier-web-app-productio-ecs-task-"
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

resource "aws_iam_role_policy" "ecs_task_permissions" {
  name = "${var.project_name}-${var.environment}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.terraform_remote_state.data.outputs.s3_bucket_arn,
          "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowSecretsManagerAccess"
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [
          data.terraform_remote_state.data.outputs.db_secret_arn,
          aws_secretsmanager_secret.app_secret_1.arn,
          aws_secretsmanager_secret.app_secret_2.arn
        ]
      },
      {
        Sid    = "AllowRDSDbConnect"
        Effect = "Allow"
        Action = "rds-db:connect"
        Resource = "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_identifier}/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "ecs_app" {
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
  tags                     = var.tags

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.app.name}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DB_ENDPOINT", value = data.terraform_remote_state.data.outputs.db_endpoint },
        { name = "DB_PORT", value = data.terraform_remote_state.data.outputs.db_port },
        { name = "DB_NAME", value = data.terraform_remote_state.data.outputs.db_name },
        { name = "REDIS_ENDPOINT", value = data.terraform_remote_state.data.outputs.redis_primary_endpoint },
        { name = "REDIS_PORT", value = data.terraform_remote_state.data.outputs.redis_port },
        { name = "S3_BUCKET_NAME", value = data.terraform_remote_state.data.outputs.s3_bucket_id }
      ]
      secrets = [
        { name = "DB_CREDENTIALS", valueFrom = data.terraform_remote_state.data.outputs.db_secret_arn },
        { name = "APP_SECRET_1", valueFrom = aws_secretsmanager_secret.app_secret_1.arn },
        { name = "APP_SECRET_2", valueFrom = aws_secretsmanager_secret.app_secret_2.arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      essential = true
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"
  tags            = var.tags

  network_configuration {
    subnets          = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.networking.outputs.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    aws_iam_role_policy.ecs_task_permissions
  ]
}

resource "aws_appautoscaling_target" "ecs_app_cpu" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.ecs_min_capacity
  max_capacity       = var.ecs_max_capacity
  tags               = var.tags
}

resource "aws_appautoscaling_policy" "ecs_app_cpu" {
  name               = "${var.project_name}-${var.environment}-ecs-app-cpu-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_app_cpu.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Secrets Manager (RULE 15, RULE 49)
resource "aws_secretsmanager_secret" "app_secret_1" {
  name_prefix             = "${var.project_name}-${var.environment}-app-secret-1-"
  kms_key_id              = aws_kms_key.secrets_manager.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "app_secret_1" {
  secret_arn = aws_secretsmanager_secret.app_secret_1.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSAndLambdaAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.ecs_task.arn,
            aws_iam_role.secret_rotation_lambda.arn
          ]
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.app_secret_1.arn
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "app_secret_2" {
  name_prefix             = "${var.project_name}-${var.environment}-app-secret-2-"
  kms_key_id              = aws_kms_key.secrets_manager.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "app_secret_2" {
  secret_arn = aws_secretsmanager_secret.app_secret_2.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task.arn
        }
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.app_secret_2.arn
      }
    ]
  })
}

# Secret Rotation Lambda (for app_secret_1)
data "archive_file" "rotation" {
  type = "zip"
  source_content = <<-PY
    import json
    def lambda_handler(event, context):
        # This is a placeholder for a real rotation function.
        # In a real scenario, this function would connect to the service
        # that uses the secret, generate a new secret, update the service,
        # and then update Secrets Manager.
        print(f"Rotating secret for event: {json.dumps(event)}")
        return {"statusCode": 200, "body": json.dumps("rotation placeholder")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/rotation.zip"
}

resource "aws_iam_role" "secret_rotation_lambda" {
  name_prefix        = "three-tier-web-secret-rotation-lambda-"
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

resource "aws_iam_role_policy" "secret_rotation_lambda_policy" {
  name = "${var.project_name}-${var.environment}-secret-rotation-lambda-policy"
  role = aws_iam_role.secret_rotation_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-${var.environment}-secret-rotation-lambda-*"
      },
      {
        Sid    = "AllowSecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.app_secret_1.arn
      },
      {
        Sid    = "AllowKMSDecrypt"
        Effect = "Allow"
        Action = "kms:Decrypt"
        Resource = aws_kms_key.secrets_manager.arn
      }
    ]
  })
}

resource "aws_lambda_function" "secret_rotation" {
  function_name    = "${var.project_name}-${var.environment}-secret-rotation-lambda"
  role             = aws_iam_role.secret_rotation_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.rotation.output_path
  source_code_hash = data.archive_file.rotation.output_base64sha256
  timeout          = 300 # 5 minutes
  memory_size      = 128 # Minimum memory
  tags             = var.tags

  tracing_config {
    mode = "Active"
  }

  reserved_concurrent_executions = 1 # Limit concurrency for rotation lambda
}

resource "aws_secretsmanager_secret_rotation" "app_secret_1_rotation" {
  secret_id           = aws_secretsmanager_secret.app_secret_1.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# Route53 DNS Record
resource "aws_route53_record" "alb_dns" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.app_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# CloudWatch Alarms (RULE 35)
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    LoadBalancer = aws_lb.main.arn
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-free-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_free_storage_threshold_bytes # e.g., 20GB in bytes
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-elasticache-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  dimensions = {
    CacheClusterId = var.elasticache_cluster_id
  }
  tags = var.tags
}
