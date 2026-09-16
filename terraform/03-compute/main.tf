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

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "random_id" "kms_cloudtrail_suffix" {
  byte_length = 4
}

resource "random_id" "kms_config_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  # RULE 14b: Performance Insights is not supported on all instance classes.
  # This local ensures it's only enabled when supported.
  enable_performance_insights = !contains(["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"], var.db_instance_class)
}

# KMS Keys
resource "aws_kms_key" "main" {
  description             = var.kms_key_description
  deletion_window_in_days = 30
  enable_key_rotation     = var.kms_key_enable_key_rotation
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
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSQS"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSNS"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowLambda"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
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

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-main-${random_id.kms_main_suffix.hex}" # RULE 29
  target_key_id = aws_kms_key.main.key_id
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
  tags = var.tags
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}" # RULE 27, 29
  target_key_id = aws_kms_key.logs.key_id
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
          "kms:Encrypt",
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

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-${var.environment}-cloudtrail-${random_id.kms_cloudtrail_suffix.hex}" # RULE 29
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
          "kms:Encrypt",
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

resource "aws_kms_alias" "config" {
  name          = "alias/${var.project_name}-${var.environment}-config-${random_id.kms_config_suffix.hex}" # RULE 29
  target_key_id = aws_kms_key.config.key_id
}

# IAM Roles and Policies
resource "aws_iam_role" "lambda_api_handler" {
  name_prefix        = "production-serverl-lambda-api-handler-" # RULE 26
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

resource "aws_iam_role_policy_attachment" "lambda_api_handler_basic_execution" {
  role       = aws_iam_role.lambda_api_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_api_handler_vpc_access" {
  role       = aws_iam_role.lambda_api_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_api_handler_access" {
  name = "${var.project_name}-${var.environment}-lambda-api-handler-access"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "${data.terraform_remote_state.data.outputs.dynamodb_table_arn}",
          "${data.terraform_remote_state.data.outputs.dynamodb_table_arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.third_party_api_keys.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = [
          "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.main.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_async_processor" {
  name_prefix        = "production-ser-lambda-async-processor-" # RULE 26
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

resource "aws_iam_role_policy_attachment" "lambda_async_processor_basic_execution" {
  role       = aws_iam_role.lambda_async_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_async_processor_vpc_access" {
  role       = aws_iam_role.lambda_async_processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_async_processor_access" {
  name = "${var.project_name}-${var.environment}-lambda-async-processor-access"
  role = aws_iam_role.lambda_async_processor.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.sqs_main_queue.arn,
          aws_sqs_queue.sqs_dlq.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.main.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "secrets_manager_rotation" {
  name_prefix        = "production-serverles-secrets-rotation-" # RULE 26
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

resource "aws_iam_role_policy_attachment" "secrets_manager_rotation_basic_execution" {
  role       = aws_iam_role.secrets_manager_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "secrets_manager_rotation_access" {
  name = "${var.project_name}-${var.environment}-secrets-rotation-access"
  role = aws_iam_role.secrets_manager_rotation.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = [
          aws_secretsmanager_secret.third_party_api_keys.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.main.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "eventbridge_to_sqs" {
  name_prefix        = "production-serverl-eventbridge-to-sqs-" # RULE 26
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

resource "aws_iam_role_policy" "eventbridge_to_sqs_policy" {
  name = "${var.project_name}-${var.environment}-eventbridge-to-sqs-policy"
  role = aws_iam_role.eventbridge_to_sqs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.sqs_main_queue.arn
    }]
  })
}

resource "aws_iam_role" "cloudtrail" {
  name_prefix        = "production-serverless-prod-cloudtrail-" # RULE 26
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

resource "aws_iam_role_policy" "cloudtrail_s3_access" {
  name = "${var.project_name}-${var.environment}-cloudtrail-s3-access"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_logs_access" {
  name = "${var.project_name}-${var.environment}-cloudtrail-cloudwatch-logs-access"
  role = aws_iam_role.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:PutLogEvents"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogStream"
        Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role" "config" {
  name_prefix        = "production-serverless-producti-config-" # RULE 26
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

resource "aws_iam_role_policy" "config_s3_access" {
  name = "${var.project_name}-${var.environment}-config-s3-access"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_logs.arn}/AWSConfig/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_logs.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "config_sns_access" {
  name = "${var.project_name}-${var.environment}-config-sns-access"
  role = aws_iam_role.config.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.config_notifications.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_read_only" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # Config needs read-only access to all resources
}

resource "aws_iam_role" "cognito_unauthenticated" {
  name_prefix        = "production-serverless-cognito-unauth-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Condition = {
        StringEquals = { "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id }
        "ForAnyValue:StringLike" = { "cognito-identity.amazonaws.com:amr" = "unauthenticated" }
      }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "cognito_unauthenticated_policy" {
  name = "${var.project_name}-${var.environment}-cognito-unauth-policy"
  role = aws_iam_role.cognito_unauthenticated.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["mobileanalytics:PutEvents", "cognito-sync:"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "cognito_authenticated" {
  name_prefix        = "production-serverless-pr-cognito-auth-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Condition = {
        StringEquals = { "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id }
        "ForAnyValue:StringLike" = { "cognito-identity.amazonaws.com:amr" = "authenticated" }
      }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "${var.project_name}-${var.environment}-cognito-auth-policy"
  role = aws_iam_role.cognito_authenticated.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["mobileanalytics:PutEvents", "cognito-sync:", "cognito-identity:"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke"
        ]
        Resource = [
          "${aws_apigatewayv2_api.main.execution_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "sns_publish" {
  name_prefix        = "production-serverless-pro-sns-publish-" # RULE 26
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
    }]
  })
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "sns_publish_policy" {
  name = "${var.project_name}-${var.environment}-sns-publish-policy"
  role = aws_iam_role.sns_publish.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sns:Publish"
      Resource = aws_sns_topic.alarms.arn
    }]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}-api"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_api_handler" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-api-handler"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_async_processor" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-async-processor"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "secrets_manager_rotation" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-secrets-rotation"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days # RULE 38
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "config" {
  name              = "/aws/config/${var.project_name}-${var.environment}"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "sqs_dlq_alarm" {
  name              = "/aws/sqs/${var.project_name}-${var.environment}-dlq-alarm"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "root_usage_filter" {
  name              = "/aws/security/${var.project_name}-${var.environment}-root-usage"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "mfa_filter" {
  name              = "/aws/security/${var.project_name}-${var.environment}-mfa-console-login"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "unauthorized_api_filter" {
  name              = "/aws/security/${var.project_name}-${var.environment}-unauthorized-api"
  retention_in_days = var.audit_log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.main.arn # RULE 45
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

resource "aws_sns_topic" "config_notifications" {
  name              = "${var.project_name}-${var.environment}-config-notifications"
  kms_master_key_id = aws_kms_key.main.arn # RULE 45
  tags              = var.tags
}

resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowConfig"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.config_notifications.arn
    }]
  })
}

# Route53 Hosted Zone and Records
resource "aws_route53_zone" "main" {
  name = var.hosted_zone
  tags = var.tags
}

resource "aws_route53_record" "api_gateway_cname" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.api_gateway_custom_domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name]
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# ACM Certificate
resource "aws_acm_certificate" "main" {
  domain_name       = var.api_gateway_custom_domain
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = var.cognito_user_pool_name
  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  mfa_configuration = "OPTIONAL"
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # For production, use SES
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  tags = var.tags
}

resource "aws_cognito_user_pool_client" "main" {
  name                          = "${var.project_name}-${var.environment}-app-client"
  user_pool_id                  = aws_cognito_user_pool.main.id
  explicit_auth_flows           = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity        = 30
  generate_secret               = true # Required for server-side apps
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id  = aws_cognito_user_pool_client.main.id
    provider_name = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
  tags = var.tags
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id
  roles = {
    "authenticated"   = aws_iam_role.cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }
}

# VPC Interface Endpoints (for Lambda to access AWS services privately)
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoint-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "vpc_endpoint_ingress_private_subnets" {
  security_group_id = aws_security_group.vpc_endpoint.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = data.terraform_remote_state.networking.outputs.private_subnet_cidrs # Assuming private_subnet_cidrs is an output
  description       = "Allow all traffic from private subnets"
}

resource "aws_security_group_rule" "vpc_endpoint_egress_private_subnets" {
  security_group_id = aws_security_group.vpc_endpoint.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  description       = "Allow all traffic within VPC" # RULE 8 Pattern A
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags              = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags              = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
  tags              = var.tags
}

# API Gateway v2 (HTTP API)
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_domain_name" "main" {
  domain_name = var.api_gateway_custom_domain
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  tags = var.tags
}

resource "aws_apigatewayv2_api_mapping" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main.id
  stage       = aws_apigatewayv2_stage.main.id
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      caller                  = "$context.identity.caller"
      user                    = "$context.identity.user"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      domainName              = "$context.domainName"
      error_message           = "$context.error.message"
      integration_error       = "$context.integrationErrorMessage"
      integration_status      = "$context.integration.status"
      integration_latency     = "$context.integration.latency"
      integration_response_status = "$context.integration.response.status"
    })
  }
  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_api_handler" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda_api_handler.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000 # Max 29 seconds for HTTP API
}

resource "aws_apigatewayv2_route" "api_handler_root" {
  api_id        = aws_apigatewayv2_api.main.id
  route_key     = "ANY /{proxy+}"
  target        = "integrations/${aws_apigatewayv2_integration.lambda_api_handler.id}"
  authorization_type = "NONE" # Public access for now, can be changed to JWT/AWS_IAM
}

# Lambda Functions
data "archive_file" "lambda_api_handler" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3

    def handler(event, context):
        print(f"Received event: {json.dumps(event)}")
        
        # Example: Accessing Secrets Manager
        secrets_client = boto3.client('secretsmanager')
        try:
            secret_name = os.environ.get('THIRD_PARTY_API_KEY_SECRET_ARN')
            if secret_name:
                get_secret_value_response = secrets_client.get_secret_value(SecretId=secret_name)
                api_key = get_secret_value_response['SecretString']
                print(f"Successfully retrieved API key from Secrets Manager.")
            else:
                print("THIRD_PARTY_API_KEY_SECRET_ARN not set in environment.")
        except Exception as e:
            print(f"Error retrieving secret: {e}")

        # Example: Publishing to EventBridge
        events_client = boto3.client('events')
        try:
            events_client.put_events(
                Entries=[
                    {
                        'Source': 'custom.api',
                        'DetailType': 'ApiRequestProcessed',
                        'Detail': json.dumps({'message': 'API request processed', 'requestId': event.get('requestContext', {}).get('requestId')}),
                        'EventBusName': 'default'
                    }
                ]
            )
            print("Event published to EventBridge.")
        except Exception as e:
            print(f"Error publishing event to EventBridge: {e}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "API request processed successfully!"})
        }
  PY
  source_content_filename = "app.py"
  output_path             = "${path.module}/build/lambda_api_handler.zip"
}

resource "aws_lambda_function" "lambda_api_handler" {
  function_name    = "${var.project_name}-${var.environment}-api-handler"
  role             = aws_iam_role.lambda_api_handler.arn
  handler          = var.lambda_api_handler_handler
  runtime          = var.lambda_api_handler_runtime
  filename         = data.archive_file.lambda_api_handler.output_path
  source_code_hash = data.archive_file.lambda_api_handler.output_base64sha256
  memory_size      = var.lambda_api_handler_memory_mb
  timeout          = 30 # seconds
  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }
  environment {
    variables = {
      PROJECT_NAME                  = var.project_name
      ENVIRONMENT                   = var.environment
      THIRD_PARTY_API_KEY_SECRET_ARN = aws_secretsmanager_secret.third_party_api_keys.arn
      DYNAMODB_TABLE_NAME           = data.terraform_remote_state.data.outputs.dynamodb_table_name
    }
  }
  kms_key_arn = aws_kms_key.main.arn # RULE "Lambda environment variables encryption"
  tracing_config {
    mode = "Active" # RULE 48
  }
  reserved_concurrent_executions = 100 # RULE 48
  tags                           = var.tags
}

resource "aws_lambda_permission" "api_gateway_to_lambda_api_handler" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*"
}

data "archive_file" "lambda_async_processor" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3

    def handler(event, context):
        print(f"Received SQS event: {json.dumps(event)}")
        sqs_client = boto3.client('sqs')
        for record in event['Records']:
            message_body = json.loads(record['body'])
            print(f"Processing message: {message_body}")
            # Simulate processing
            if "fail" in message_body.get("message", "").lower():
                raise Exception("Simulated processing failure")
            print(f"Message processed successfully: {message_body}")
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Messages processed"})
        }
  PY
  source_content_filename = "processor.py"
  output_path             = "${path.module}/build/lambda_async_processor.zip"
}

resource "aws_lambda_function" "lambda_async_processor" {
  function_name    = "${var.project_name}-${var.environment}-async-processor"
  role             = aws_iam_role.lambda_async_processor.arn
  handler          = var.lambda_async_processor_handler
  runtime          = var.lambda_async_processor_runtime
  filename         = data.archive_file.lambda_async_processor.output_path
  source_code_hash = data.archive_file.lambda_async_processor.output_base64sha256
  memory_size      = var.lambda_async_processor_memory_mb
  timeout          = 60 # seconds
  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }
  environment {
    variables = {
      PROJECT_NAME = var.project_name
      ENVIRONMENT  = var.environment
    }
  }
  kms_key_arn = aws_kms_key.main.arn # RULE "Lambda environment variables encryption"
  tracing_config {
    mode = "Active" # RULE 48
  }
  reserved_concurrent_executions = 50 # RULE 48
  dead_letter_config {
    target_arn = aws_sqs_queue.sqs_dlq.arn # RULE "Lambda dead letter queue"
  }
  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_async_processor" {
  event_source_arn = aws_sqs_queue.sqs_main_queue.arn
  function_name    = aws_lambda_function.lambda_async_processor.arn
  batch_size       = 10
  enabled          = true
}

# SQS Queues
resource "aws_sqs_queue" "sqs_main_queue" {
  name                       = "${var.project_name}-${var.environment}-main-queue"
  delay_seconds              = var.sqs_main_queue_delay_seconds
  max_message_size           = var.sqs_main_queue_max_message_size
  message_retention_seconds  = var.sqs_main_queue_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_main_queue_receive_wait_time_seconds
  visibility_timeout_seconds = var.sqs_main_queue_visibility_timeout_seconds
  redrive_policy             = "{\"deadLetterTargetArn\": \"${aws_sqs_queue.sqs_dlq.arn}\", \"maxReceiveCount\": 5}"
  kms_master_key_id          = aws_kms_key.main.arn # RULE "SQS queue required security"
  tags                       = var.tags
}

resource "aws_sqs_queue_policy" "sqs_main_queue" {
  queue_url = aws_sqs_queue.sqs_main_queue.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.sqs_main_queue.arn
      },
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource  = aws_sqs_queue.sqs_main_queue.arn
      }
    ]
  })
}

resource "aws_sqs_queue" "sqs_dlq" {
  name                      = "${var.project_name}-${var.environment}-dlq"
  message_retention_seconds = var.sqs_dlq_message_retention_seconds # RULE 42
  kms_master_key_id         = aws_kms_key.main.arn                  # RULE "SQS queue required security"
  tags                      = var.tags
}

resource "aws_sqs_queue_policy" "sqs_dlq" {
  queue_url = aws_sqs_queue.sqs_dlq.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sqs.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.sqs_dlq.arn
      },
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.sqs_dlq.arn
      }
    ]
  })
}

# EventBridge
resource "aws_cloudwatch_event_rule" "sqs_event_rule" {
  name          = "${var.project_name}-${var.environment}-sqs-event-rule"
  event_bus_name = "default"
  event_pattern = jsonencode({
    "source": ["custom.api"],
    "detail-type": ["ApiRequestProcessed"]
  })
  is_enabled = true
  tags       = var.tags
}

resource "aws_cloudwatch_event_target" "sqs_main_queue_target" {
  rule      = aws_cloudwatch_event_rule.sqs_event_rule.name
  arn       = aws_sqs_queue.sqs_main_queue.arn
  role_arn  = aws_iam_role.eventbridge_to_sqs.arn
  target_id = "SQSMainQueue"
}

# Secrets Manager
resource "aws_secretsmanager_secret" "third_party_api_keys" {
  name_prefix             = "${var.project_name}-${var.environment}-third-party-api-keys-" # RULE 15
  description             = var.secrets_manager_description
  kms_key_id              = aws_kms_key.main.arn                                          # RULE 49
  recovery_window_in_days = 30                                                            # RULE 15
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "secrets_rotation_lambda" {
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

        # Make sure the version is staged correctly
        metadata = service_client.describe_secret(SecretId=arn)
        if not metadata['RotationEnabled']:
            raise ValueError("Secret %s is not enabled for rotation" % arn)
        versions = metadata['VersionIdsToStages']
        if token not in versions:
            raise ValueError("Secret version %s has no stage for rotation of secret %s." % (token, arn))
        if versions[token] and 'AWSPENDING' not in versions[token]:
            raise ValueError("Secret version %s not staged as AWSPENDING for rotation of secret %s." % (token, arn))

        if step == 'createSecret':
            # Create a new secret version
            print("createSecret: Creating new secret version")
            # In a real scenario, generate a new API key here
            new_secret_value = "new_api_key_value_" + token
            service_client.put_secret_value(SecretId=arn, ClientRequestToken=token, SecretString=new_secret_value, VersionStages=['AWSPENDING'])
            print("createSecret: Successfully created new secret version.")

        elif step == 'setSecret':
            # This step is typically for updating the credentials in the service that uses the secret.
            # For API keys, this might involve updating the third-party service with the new key.
            # For this placeholder, we'll just log.
            print("setSecret: Updating service with new secret.")
            # Retrieve the AWSPENDING secret
            pending_secret = service_client.get_secret_value(SecretId=arn, VersionStage='AWSPENDING', ClientRequestToken=token)['SecretString']
            print(f"setSecret: Retrieved pending secret: {pending_secret[:10]}...")
            # In a real scenario, use pending_secret to update the third-party service
            print("setSecret: Service updated successfully (simulated).")

        elif step == 'testSecret':
            # Test the new secret
            print("testSecret: Testing new secret.")
            # In a real scenario, make a test call to the third-party API with the new key
            print("testSecret: New secret tested successfully (simulated).")

        elif step == 'finishSecret':
            # Finalize the rotation by moving AWSPENDING to AWSCURRENT
            print("finishSecret: Finalizing secret rotation.")
            current_version = None
            for version_id, stages in versions.items():
                if 'AWSCURRENT' in stages:
                    if version_id == token:
                        # Already current, nothing to do
                        print("finishSecret: Secret already AWSCURRENT, nothing to do.")
                        return
                    current_version = version_id
                    break

            if current_version:
                service_client.update_secret_version_stage(SecretId=arn, VersionStage='AWSCURRENT', MoveFromVersionId=current_version, MoveToVersionId=token)
                print("finishSecret: Successfully moved AWSPENDING to AWSCURRENT.")
            else:
                # No AWSCURRENT, make AWSPENDING AWSCURRENT
                service_client.update_secret_version_stage(SecretId=arn, VersionStage='AWSCURRENT', MoveToVersionId=token)
                print("finishSecret: Successfully set AWSPENDING to AWSCURRENT (no previous AWSCURRENT).")

        else:
            raise ValueError("Invalid step parameter: %s" % step)

        return {}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/secrets_rotation_lambda.zip"
}

resource "aws_lambda_function" "secrets_rotation_lambda" {
  function_name    = "${var.project_name}-${var.environment}-secrets-rotation"
  role             = aws_iam_role.secrets_manager_rotation.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.secrets_rotation_lambda.output_path
  source_code_hash = data.archive_file.secrets_rotation_lambda.output_base64sha256
  memory_size      = 128
  timeout          = 300 # 5 minutes
  environment {
    variables = {
      AWS_REGION = var.region
    }
  }
  kms_key_arn = aws_kms_key.main.arn # RULE "Lambda environment variables encryption"
  tracing_config {
    mode = "Active" # RULE 48
  }
  tags = var.tags
}

resource "aws_secretsmanager_secret_rotation" "third_party_api_keys" {
  secret_id           = aws_secretsmanager_secret.third_party_api_keys.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation_lambda.arn
  rotation_rules {
    automatically_after_days = 30
  }
}

# CloudTrail
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

resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true # RULE 38
  enable_log_file_validation    = true # RULE 38
  include_global_service_events = true # RULE 38
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*" # RULE 59
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  tags                          = var.tags
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

resource "aws_securityhub_standards_subscription" "foundational_security_best_practices" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

# AWS Config
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

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.project_name}-${var.environment}-recorder"
  role_arn = aws_iam_role.config.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name          = "${var.project_name}-${var.environment}-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_logs.id
  sns_topic_arn = aws_sns_topic.config_notifications.arn
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "${var.project_name}-${var.environment}-s3-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  name = "${var.project_name}-${var.environment}-rds-storage-encrypted"
  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "${var.project_name}-${var.environment}-iam-root-access-key-check"
  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name = "${var.project_name}-${var.environment}-encrypted-volumes"
  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "multi_region_cloudtrail_enabled" {
  name = "${var.project_name}-${var.environment}-multi-region-cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
  }
  tags = var.tags
  depends_on = [aws_config_configuration_recorder.main]
}

# CloudWatch Security Metric Filters and Alarms
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "${var.project_name}-${var.environment}-root-usage-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  metric_transformation {
    name          = "RootAccountUsage"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name          = "${var.project_name}-${var.environment}-root-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_usage.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_usage.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when root account is used"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "mfa_console_login" {
  name           = "${var.project_name}-${var.environment}-mfa-console-login-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ $.eventName = \"ConsoleLogin\" && $.additionalEventData.MFAUsed != \"Yes\" }"
  metric_transformation {
    name          = "ConsoleLoginWithoutMFA"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "mfa_console_login" {
  alarm_name          = "${var.project_name}-${var.environment}-mfa-console-login-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.mfa_console_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.mfa_console_login.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when console login without MFA occurs"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.project_name}-${var.environment}-unauthorized-api-calls-filter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
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
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when unauthorized API calls occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages_visible" {
  alarm_name          = "${var.project_name}-${var.environment}-sqs-dlq-messages-visible"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    QueueName = aws_sqs_queue.sqs_dlq.name
  }
  alarm_description = "Alarm if messages appear in the SQS DLQ"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_api_handler_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-api-handler-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    FunctionName = aws_lambda_function.lambda_api_handler.function_name
  }
  alarm_description = "Alarm if Lambda API Handler has errors"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_async_processor_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-async-processor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    FunctionName = aws_lambda_function.lambda_async_processor.function_name
  }
  alarm_description = "Alarm if Lambda Async Processor has errors"
  alarm_actions     = [aws_sns_topic.alarms.arn]
  ok_actions        = [aws_sns_topic.alarms.arn]
  tags              = var.tags
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


resource "aws_s3_bucket_versioning" "cloudtrail_logs_access_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs_access.id
  versioning_configuration { status = "Enabled" }
}


resource "aws_s3_bucket_logging" "cloudtrail_logs_access_logging" {
  bucket        = aws_s3_bucket.cloudtrail_logs_access.id
  target_bucket = aws_s3_bucket.cloudtrail_logs_access.id
  target_prefix = "access-logs/"
}
