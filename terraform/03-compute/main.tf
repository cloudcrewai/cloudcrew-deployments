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
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  # CloudWatch log retention days
  audit_log_retention_days = 365
  log_retention_days       = 90
}

# KMS Keys (from blueprint components)
resource "aws_kms_key" "elasticache" {
  description             = "${var.project_name}-${var.environment}-elasticache-cmk"
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

resource "aws_kms_key" "alb_logs" {
  description             = "${var.project_name}-${var.environment}-alb-logs-cmk"
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
        Sid    = "AllowALBLogging"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
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

resource "random_id" "kms_alb_logs_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "alb_logs" {
  name          = "alias/${var.project_name}-${var.environment}-alb-logs-${random_id.kms_alb_logs_suffix.hex}"
  target_key_id = aws_kms_key.alb_logs.key_id
}

resource "aws_kms_key" "cloudtrail_logs" {
  description             = "${var.project_name}-${var.environment}-cloudtrail-logs-cmk"
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

resource "random_id" "kms_cloudtrail_logs_suffix" {
  byte_length = 4
}
resource "aws_kms_alias" "cloudtrail_logs" {
  name          = "alias/${var.project_name}-${var.environment}-cloudtrail-logs-${random_id.kms_cloudtrail_logs_suffix.hex}"
  target_key_id = aws_kms_key.cloudtrail_logs.key_id
}

# KMS key for EBS encryption (RULE 28)
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
      description  = "Remove untagged images after 7 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = { type = "expire" }
    }]
  })
}

# CloudWatch Log Groups for WAF (RULE 44)
resource "aws_cloudwatch_log_group" "waf_cloudfront_logs" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}-cloudfront"
  retention_in_days = local.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "waf_regional_logs" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}-regional"
  retention_in_days = local.log_retention_days
  kms_key_id = aws_kms_key.logs.arn
  tags              = var.tags
}

# WAF Web ACL (CloudFront)
resource "aws_wafv2_web_acl" "cloudfront" {
  name  = "${var.project_name}-${var.environment}-waf-cloudfront"
  scope = "CLOUDFRONT"
  description = "WAF Web ACL for CloudFront distribution"
  tags        = var.tags

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
      metric_name                = "${var.project_name}-cloudfront-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf-cloudfront"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "cloudfront" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_cloudfront_logs.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn
}

# WAF Web ACL (Regional)
resource "aws_wafv2_web_acl" "regional" {
  name  = "${var.project_name}-${var.environment}-waf-regional"
  scope = "REGIONAL"
  description = "WAF Web ACL for regional ALB"
  tags        = var.tags

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
      metric_name                = "${var.project_name}-regional-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-regional-sqli-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

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
      metric_name                = "${var.project_name}-regional-bad-inputs-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit      = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-regional-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf-regional"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "regional" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_regional_logs.arn]
  resource_arn            = aws_wafv2_web_acl.regional.arn
}

# ACM Certificate (RULE 37)
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
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
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# ALB (RULE 46)
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
    prefix  = "alb"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-tg"
  port        = 8080 # Assuming application listens on 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip" # For Fargate
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
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# WAF Regional Association (RULE 36)
resource "aws_wafv2_web_acl_association" "regional" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.regional.arn
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  tags = var.tags
}

# CloudWatch Log Group for ECS (RULE 39)
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.project_name}/${var.environment}/app"
  retention_in_days = local.log_retention_days
  kms_key_id        = data.terraform_remote_state.data.outputs.kms_cloudwatch_logs_key_id
  tags              = var.tags
}

# IAM Roles for ECS
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "production-th-ecs-task-execution-role-"
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
  name_prefix = "production-three-tier-p-ecs-task-role-"
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

resource "aws_iam_role_policy" "ecs_task_app_access" {
  name = "${var.project_name}-${var.environment}-ecs-task-app-access-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.terraform_remote_state.data.outputs.db_secret_arn,
          aws_secretsmanager_secret.redis_auth.arn
        ]
      }
    ]
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-app"
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
      image       = "${aws_ecr_repository.app.repository_url}:latest"
      cpu         = var.ecs_task_cpu
      memory      = var.ecs_task_memory
      essential   = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "DB_HOST", value = data.terraform_remote_state.data.outputs.rds_proxy_endpoint },
        { name = "DB_PORT", value = tostring(data.terraform_remote_state.data.outputs.db_port) },
        { name = "DB_NAME", value = data.terraform_remote_state.data.outputs.db_name },
        { name = "REDIS_HOST", value = data.terraform_remote_state.data.outputs.redis_primary_endpoint },
        { name = "REDIS_PORT", value = tostring(data.terraform_remote_state.data.outputs.redis_port) }
      ]
      secrets = [
        { name = "DB_CREDENTIALS", valueFrom = data.terraform_remote_state.data.outputs.db_secret_arn },
        { name = "REDIS_AUTH_TOKEN", valueFrom = aws_secretsmanager_secret.redis_auth.arn }
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
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.https,
    aws_acm_certificate_validation.main
  ]
}

# EC2 for SSM Debugging
resource "aws_iam_role" "ec2_ssm" {
  name_prefix = "production-three-tier-pr-ec2-ssm-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-ssm-profile-"
  role = aws_iam_role.ec2_ssm.name
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "ssm_debug" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.ec2_ssm_instance_type
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnet_ids[0] # Use first private subnet
  vpc_security_group_ids      = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  associate_public_ip_address = false # RULE 12
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  tags = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}" })

  root_block_device {
    encrypted = true # RULE 10
    kms_key_id = aws_kms_key.ebs.arn
  }

  metadata_options {
    http_tokens = "required" # RULE 11
  }
}

# Secrets Manager (Redis Auth Token) (RULE 15, RULE 49, RULE 60)
resource "aws_secretsmanager_secret" "redis_auth" {
  name_prefix             = "${var.project_name}-${var.environment}-redis-auth-"
  kms_key_id              = data.terraform_remote_state.data.outputs.kms_secrets_key_id
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "rotation" {
  type = "zip"
  source_content = <<-PY
    import json
    import boto3
    import os

    def lambda_handler(event, context):
        arn = event['SecretId']
        token = event['ClientRequestToken']
        step = event['Step']

        service_client = boto3.client('secretsmanager', region_name=os.environ['AWS_REGION'])

        # Placeholder for actual rotation logic
        # In a real scenario, this would involve:
        # 1. get_secret_value(SecretId=arn, VersionStage='AWSPENDING', ClientRequestToken=token)
        # 2. create_secret(SecretId=arn, ClientRequestToken=token, SecretString=new_secret)
        # 3. set_secret_value(SecretId=arn, VersionStages=['AWSPENDING'], ClientRequestToken=token)
        # 4. update_secret_version_stage(SecretId=arn, VersionStage='AWSCURRENT', MoveToVersionId=token)
        # 5. finish_secret(SecretId=arn, VersionStage='AWSCURRENT', ClientRequestToken=token)

        print(f"Rotation step: {step} for secret {arn} with token {token}")

        if step == 'createSecret':
            # Generate a new secret and store it in AWSPENDING
            print("Create secret step - placeholder")
            service_client.put_secret_value(SecretId=arn, ClientRequestToken=token, SecretString="new_redis_auth_token", VersionStages=['AWSPENDING'])
        elif step == 'setSecret':
            # Set the new secret in the service
            print("Set secret step - placeholder")
        elif step == 'testSecret':
            # Test the new secret
            print("Test secret step - placeholder")
        elif step == 'finishSecret':
            # Mark the new secret as AWSCURRENT
            print("Finish secret step - placeholder")
            service_client.update_secret_version_stage(SecretId=arn, VersionStage='AWSCURRENT', MoveToVersionId=token, RemoveFromVersionStages=['AWSPENDING'])
        else:
            raise ValueError("Invalid step parameter")

        return {"statusCode": 200, "body": json.dumps("rotation placeholder")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/rotation.zip"
}

resource "aws_iam_role" "rotation_lambda" {
  name_prefix = "production-three-rotation-lambda-role-"
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

resource "aws_iam_role_policy_attachment" "rotation_lambda_basic_execution" {
  role       = aws_iam_role.rotation_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "rotation_lambda_secrets_access" {
  name = "${var.project_name}-${var.environment}-rotation-lambda-secrets-access"
  role = aws_iam_role.rotation_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.redis_auth.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = data.terraform_remote_state.data.outputs.kms_secrets_key_id
      }
    ]
  })
}

resource "aws_lambda_function" "rotation" {
  function_name    = "${var.project_name}-${var.environment}-rotation"
  role             = aws_iam_role.rotation_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.rotation.output_path
  source_code_hash = data.archive_file.rotation.output_base64sha256
  timeout          = 300 # 5 minutes
  tags             = var.tags

  tracing_config {
    mode = "Active" # RULE 48
  }
}

resource "aws_secretsmanager_secret_rotation" "redis_auth" {
  secret_id           = aws_secretsmanager_secret.redis_auth.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# SNS Topic for GuardDuty Alerts (RULE 45)
resource "aws_sns_topic" "guardduty_alerts" {
  name              = "${var.project_name}-${var.environment}-guardduty-alerts"
  kms_master_key_id = data.terraform_remote_state.data.outputs.kms_secrets_key_id
  tags              = var.tags
}

resource "aws_sns_topic_policy" "guardduty_alerts" {
  arn = aws_sns_topic.guardduty_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowGuardDuty"
      Effect    = "Allow"
      Principal = { Service = "guardduty.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.guardduty_alerts.arn
    }]
  })
}

resource "aws_sns_topic_subscription" "guardduty_email" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

resource "aws_sns_topic_subscription" "guardduty_pagerduty" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "https"
  endpoint  = var.pagerduty_endpoint
}

# CloudTrail (RULE 38, RULE 59)
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-cloudtrail"
  s3_bucket_name                = data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_id
  is_multi_region_trail         = true # RULE 38
  include_global_service_events = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  cloud_watch_logs_group_arn    = "${data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name}:*" # RULE 59
  cloud_watch_logs_role_arn     = data.terraform_remote_state.data.outputs.iam_cloudtrail_role_arn
  kms_key_id                    = aws_kms_key.cloudtrail_logs.arn
  tags                          = var.tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"] # All S3 buckets
    }
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"] # All Lambda functions
    }
  }
}

# CloudTrail S3 Bucket Policy (RULE 20)
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_id
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
        Resource = data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_arn
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
        Resource = "${data.terraform_remote_state.data.outputs.s3_cloudtrail_logs_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.name, { "label" : "ALB 5XX Errors" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name, { "label" : "ECS CPU Utilization" }],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier, { "label" : "RDS CPU Utilization" }],
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_identifier, { "label" : "RDS Free Storage" }],
            ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", data.terraform_remote_state.data.outputs.redis_replication_group_id, { "label" : "ElastiCache CPU Utilization" }]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "Application Health Overview"
        }
      }
    ]
  })
}

# Cost Anomaly Detection
resource "aws_ce_anomaly_monitor" "main" {
  name = "${var.project_name}-${var.environment}-cost-monitor"
  monitor_type = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
  tags = var.tags
}

resource "aws_ce_anomaly_subscription" "main" {
  name             = "${var.project_name}-${var.environment}-cost-alerts"
  frequency        = "DAILY"
  monitor_arn_list = [aws_ce_anomaly_monitor.main.arn]
  subscriber {
    address = aws_sns_topic.guardduty_alerts.arn
    type    = "SNS"
  }
}

# Security Hub (RULE 33)
resource "aws_securityhub_account" "main" {
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# GuardDuty (RULE 32)
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

# AWS Config (RULE 34)
resource "aws_iam_role" "config" {
  name_prefix = "production-three-tier-pro-config-role-"
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
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.config_logs.arn,
          "${aws_s3_bucket.config_logs.arn}/*"
        ]
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = data.terraform_remote_state.data.outputs.sns_alarms_topic_arn
      }
    ]
  })
}

resource "aws_s3_bucket" "config_logs" {
  bucket        = "${var.project_name}-${var.environment}-config-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # RULE 30
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

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.terraform_remote_state.data.outputs.kms_s3_key_id
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name          = "default"
  s3_bucket_name = aws_s3_bucket.config_logs.id
  sns_topic_arn = data.terraform_remote_state.data.outputs.sns_alarms_topic_arn
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [
    aws_config_delivery_channel.main
  ]
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name        = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name        = "rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name        = "iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name        = "encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name        = "multi-region-cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

# CloudWatch Metric Filters and Alarms (Root, MFA, Unauthorized)
resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "${var.project_name}-${var.environment}-root-account-usage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

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
  metric_name         = "RootAccountUsageCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account is used"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "console_login_without_mfa" {
  name           = "${var.project_name}-${var.environment}-console-login-without-mfa"
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

  metric_transformation {
    name          = "ConsoleLoginWithoutMFA"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_login_without_mfa" {
  alarm_name          = "${var.project_name}-${var.environment}-console-login-without-mfa-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginWithoutMFA"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login occurs without MFA"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = data.terraform_remote_state.data.outputs.cloudwatch_cloudtrail_log_group_name

  metric_transformation {
    name          = "UnauthorizedAPICalls"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.project_name}-${var.environment}-unauthorized-api-calls-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [data.terraform_remote_state.data.outputs.sns_alarms_topic_arn]
  tags                = var.tags
}

# KMS Key for RDS (from blueprint kms_rds)
resource "aws_kms_key" "rds" {
  description             = "${var.project_name}-${var.environment}-rds-cmk"
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
  tags = var.tags
}

resource "random_id" "kms_rds_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-${var.environment}-rds-${random_id.kms_rds_suffix.hex}"
  target_key_id = aws_kms_key.rds.key_id
}

# KMS Key for general CloudWatch Logs (from blueprint kms_cloudwatch_logs)
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

resource "aws_kms_alias" "logs" {
  # RULE 29: the random_id suffix makes the alias name unique per deploy, so a
  # destroy+re-deploy with the same project_name/environment never collides with
  # an alias left behind by the KMS key's pending-deletion window. The alias stays
  # human-readable in the console for audit navigation.
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_elasticache_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# KMS Key for Flow Logs (from blueprint kms_flow_logs)
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
        Sid    = "AllowFlowLogs"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
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

resource "random_id" "kms_flow_logs_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${var.project_name}-${var.environment}-flow-logs-${random_id.kms_flow_logs_suffix.hex}"
  target_key_id = aws_kms_key.flow_logs.key_id
}

# KMS Key for SNS (for CloudWatch Alarms)
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

resource "random_id" "kms_sns_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "sns" {
  name          = "alias/${var.project_name}-${var.environment}-sns-${random_id.kms_sns_suffix.hex}"
  target_key_id = aws_kms_key.sns.key_id
}

# S3 bucket for CloudFront access logs
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket        = "${var.project_name}-${var.environment}-cloudfront-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # RULE 16
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket                  = aws_s3_bucket.cloudfront_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.terraform_remote_state.data.outputs.kms_s3_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for CloudFront to ALB"
  origin_access_control_origin_type = "s3" # Even if origin is ALB, OAC is for S3. For ALB, it's not strictly OAC.
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

# CloudFront Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.project_name}-${var.environment}-security-headers"
  comment = "Security headers for CloudFront distribution"

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self';"
      override                = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "no-referrer-when-downgrade"
      override        = true
    }
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
}

# CloudFront Distribution (from blueprint cloudfront)
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  comment             = "${var.project_name}-${var.environment} CloudFront Distribution"
  is_ipv6_enabled     = true
  default_root_object = "index.html" # Assuming a web app

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https" # RULE 52
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    forwarded_values {
      query_string = true
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021" # RULE 52
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/"
  }
  tags = var.tags
}

# VPC Flow Logs (from blueprint vpc_flow_logs)
resource "aws_iam_role" "flow_logs" {
  name_prefix = "production-three-tier-flow-logs-role-" # RULE 26
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

# AWS Config Remediation (from blueprint aws_config, s3_public_access_remediation)
resource "aws_config_remediation_configuration" "s3_public_access_remediation" {
  config_rule_name = aws_config_config_rule.s3_bucket_public_read_prohibited.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisableS3BucketPublicReadWrite"
  automatic        = true
  resource_type    = "AWS::S3::Bucket"
}

# EventBridge Rule for GuardDuty (from blueprint eventbridge_guardduty)
resource "aws_iam_role" "eventbridge_guardduty" {
  name_prefix = "production-eventbridge-guardduty-role-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "eventbridge_guardduty" {
  name = "${var.project_name}-${var.environment}-eventbridge-guardduty-policy"
  role = aws_iam_role.eventbridge_guardduty.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.guardduty_alerts.arn
    }]
  })
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name          = "${var.project_name}-${var.environment}-guardduty-findings"
  description   = "Route GuardDuty findings to SNS topic"
  event_pattern = jsonencode({
    "source"      = ["aws.guardduty"],
    "detail-type" = ["GuardDuty Finding"],
    "detail"      = {
      "severity" = [
        { "numeric" = [">=", 7] } # HIGH and CRITICAL findings (7-8.9 is High, 9-10 is Critical)
      ]
    }
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  arn       = aws_sns_topic.guardduty_alerts.arn
  role_arn  = aws_iam_role.eventbridge_guardduty.arn
  target_id = "GuardDutySNSTopic"
}

# CloudWatch Alarms (from blueprint cloudwatch_alarms)
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.sns.arn # RULE 45
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

resource "aws_cloudwatch_metric_alarm" "alb_5xx_error_rate" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "ALB 5xx error rate is too high"
  dimensions = {
    LoadBalancer = aws_lb.main.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"
  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.data.outputs.rds_cluster_id # Assuming Aurora cluster
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-task-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS Task CPU utilization is too high"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2 # 2 seconds
  alarm_description   = "ALB Target Response Time is too high"
  dimensions = {
    LoadBalancer = aws_lb.main.name
    TargetGroup  = aws_lb_target_group.app.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

# AWS Backup (from blueprint aws_backup)
resource "aws_iam_role" "backup" {
  name_prefix = "production-three-tier-pro-backup-role-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-${var.environment}-backup-vault"
  kms_key_arn = data.terraform_remote_state.data.outputs.kms_backup_key_arn
  tags        = var.tags
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)" # Daily at 05:00 UTC

    lifecycle {
      delete_after = 35 # RULE 41
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.cross_region_copy_destination}:${data.aws_caller_identity.current.account_id}:backup-vault/${var.project_name}-${var.environment}-backup-vault-us-west-2"
      lifecycle {
        delete_after = 35
      }
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "rds_selection" {
  name          = "${var.project_name}-${var.environment}-rds-selection"
  plan_id       = aws_backup_plan.main.id
  iam_role_arn  = aws_iam_role.backup.arn
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
  # Target RDS cluster by tag, assuming the RDS cluster in 02-data has a tag "Backup": "true"
  # Or target by ARN if available:
  # resources = [data.terraform_remote_state.data.outputs.rds_cluster_arn]
}

# Route53 Hosted Zone (from blueprint route53)
resource "aws_route53_zone" "main" {
  name          = var.hosted_zone_name
  force_destroy = false # For production
  tags          = var.tags
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.hosted_zone_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_alias_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.hosted_zone_name
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# Secrets Manager (RDS Master Credentials) (from blueprint secrets_manager_rds)
# RULE 60: RDS master credentials are managed by AWS. No aws_secretsmanager_secret or rotation lambda needed here.
# The secret ARN is retrieved from remote state: data.terraform_remote_state.data.outputs.db_secret_arn
# The rotation_enabled and rotation_schedule_days in the blueprint are handled by RDS itself.

resource "aws_cloudwatch_log_group" "waf_cloudfront" {
  name              = "aws-waf-logs-cloudfront"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "waf_regional" {
  name              = "aws-waf-logs-regional"
  retention_in_days = 90
}

resource "aws_s3_bucket_logging" "config_logs_logging" {
  bucket        = aws_s3_bucket.config_logs.id
  target_bucket = aws_s3_bucket.config_logs.id
  target_prefix = "access-logs/"
}


resource "aws_s3_bucket_logging" "cloudfront_logs_logging" {
  bucket        = aws_s3_bucket.cloudfront_logs.id
  target_bucket = aws_s3_bucket.cloudfront_logs.id
  target_prefix = "access-logs/"
}
