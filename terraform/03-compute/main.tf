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

data "aws_route53_zone" "selected" {
  name         = var.hosted_zone_name
  private_zone = false
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
}

# KMS Key for general encryption (Secrets Manager, SNS, SQS, Lambda Env Vars)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-main-cmk"
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
        Sid    = "AllowLambdaKmsAccess"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
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
        Sid    = "AllowSecretsManagerKmsAccess"
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
      },
      {
        Sid    = "AllowSnsKmsAccess"
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
      },
      {
        Sid    = "AllowSqsKmsAccess"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
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
  name          = "alias/${var.project_name}-${var.environment}-main-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS Key for CloudWatch Logs encryption
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
  name          = "alias/${var.project_name}-${var.environment}-compute-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# CloudWatch Log Group for API Gateway Access Logs
resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}-api-access"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for Lambda API Handler
resource "aws_cloudwatch_log_group" "lambda_api_handler" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-api-handler"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# CloudWatch Log Group for SQS DLQ Alarms
resource "aws_cloudwatch_log_group" "sqs_dlq_alarms" {
  name              = "/${var.project_name}/${var.environment}/sqs-dlq-alarms"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "alarms" {
  name              = "${var.project_name}-${var.environment}-alarms"
  kms_master_key_id = aws_kms_key.main.arn
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

# IAM Role for Lambda API Handler
resource "aws_iam_role" "lambda_api_handler" {
  name_prefix = "production-se-lambda-api-handler-role-"
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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_api_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_execution" {
  role       = aws_iam_role.lambda_api_handler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets_manager" {
  name = "${var.project_name}-${var.environment}-lambda-secrets-manager-policy"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.api_key.arn
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-${var.environment}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_eventbridge" {
  name = "${var.project_name}-${var.environment}-lambda-eventbridge-policy"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "events:PutEvents"
      Effect   = "Allow"
      Resource = aws_cloudwatch_event_bus.main.arn
    }]
  })
}

resource "aws_iam_role_policy" "lambda_kms" {
  name = "${var.project_name}-${var.environment}-lambda-kms-policy"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      Effect   = "Allow"
      Resource = aws_kms_key.main.arn
    }]
  })
}

# IAM Role for API Gateway to invoke Lambda
resource "aws_iam_role" "api_gateway_lambda_invoke" {
  name_prefix = "production-s-apigw-lambda-invoke-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "api_gateway_lambda_invoke" {
  name = "${var.project_name}-${var.environment}-apigw-lambda-invoke-policy"
  role = aws_iam_role.api_gateway_lambda_invoke.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "lambda:InvokeFunction"
      Effect   = "Allow"
      Resource = aws_lambda_function.api_handler.arn
    }]
  })
}

# IAM Role for EventBridge to send messages to SQS
resource "aws_iam_role" "eventbridge_sqs" {
  name_prefix = "production-serve-eventbridge-sqs-role-"
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

resource "aws_iam_role_policy" "eventbridge_sqs" {
  name = "${var.project_name}-${var.environment}-eventbridge-sqs-policy"
  role = aws_iam_role.eventbridge_sqs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sqs:SendMessage"
      Effect   = "Allow"
      Resource = aws_sqs_queue.main.arn
    }]
  })
}

# IAM Role for Cognito Authenticated Users
resource "aws_iam_role" "cognito_auth_role" {
  name_prefix = "production-serverle-cognito-auth-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "cognito_auth_policy" {
  role       = aws_iam_role.cognito_auth_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser" # Example, adjust as needed
}

# IAM Role for Cognito Unauthenticated Users
resource "aws_iam_role" "cognito_unauth_role" {
  name_prefix = "production-server-cognito-unauth-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "unauthenticated"
        }
      }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "cognito_unauth_policy" {
  role       = aws_iam_role.cognito_unauth_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly" # Example, adjust as needed
}

# IAM Role for CloudWatch Alarms to publish to SNS
resource "aws_iam_role" "cloudwatch_alarms" {
  name_prefix = "production-ser-cloudwatch-alarms-role-"
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

resource "aws_iam_role_policy" "cloudwatch_alarms" {
  name = "${var.project_name}-${var.environment}-cloudwatch-alarms-policy"
  role = aws_iam_role.cloudwatch_alarms.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sns:Publish"
      Effect   = "Allow"
      Resource = aws_sns_topic.alarms.arn
    }]
  })
}

# ACM Certificate for API Gateway Custom Domain
resource "aws_acm_certificate" "api_domain" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "api_domain" {
  certificate_arn         = aws_acm_certificate.api_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.api_domain_validation : record.fqdn]
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_domain_name" "main" {
  domain_name = var.api_domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_domain.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  tags = var.tags
}

resource "aws_apigatewayv2_api_mapping" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = aws_apigatewayv2_domain_name.main.domain_name
  stage       = aws_apigatewayv2_stage.main.id
}

resource "aws_route53_record" "api_domain_cname" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.api_domain_name
  type    = "CNAME"
  records = [aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name]
  ttl     = 300
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
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
      integration_latency_ms  = "$context.integration.latency"
      authorizer_error        = "$context.authorizer.error"
      authorizer_status       = "$context.authorizer.status"
      authorizer_latency_ms   = "$context.authorizer.latency"
      authorizer_principal_id = "$context.authorizer.principalId"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }

  tags = var.tags
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  name             = "${var.project_name}-${var.environment}-cognito-authorizer"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.main.id]
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

resource "aws_apigatewayv2_integration" "lambda_api_handler" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.api_handler.invoke_arn
  payload_format_version = "2.0"
  credentials_arn    = aws_iam_role.api_gateway_lambda_invoke.arn
}

resource "aws_apigatewayv2_route" "any_path" {
  api_id        = aws_apigatewayv2_api.main.id
  route_key     = "ANY /{proxy+}"
  target        = "integrations/${aws_apigatewayv2_integration.lambda_api_handler.id}"
  authorization_type = "JWT" # Use JWT for authenticated routes
  authorizer_id = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "health_check" {
  api_id        = aws_apigatewayv2_api.main.id
  route_key     = "GET /health"
  target        = "integrations/${aws_apigatewayv2_integration.lambda_api_handler.id}"
  authorization_type = "NONE" # Public health check
}

# Lambda API Handler Function
data "archive_file" "lambda_api_handler" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import logging

    logger = logging.getLogger()
    logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

    def handler(event, context):
        logger.info(f"Received event: {json.dumps(event)}")

        path = event.get('rawPath')
        method = event.get('requestContext', {}).get('http', {}).get('method')

        if path == '/health' and method == 'GET':
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"status": "ok"})
            }

        # Example of accessing environment variables
        db_endpoint = os.environ.get('DB_ENDPOINT')
        db_port = os.environ.get('DB_PORT')
        db_name = os.environ.get('DB_NAME')
        redis_endpoint = os.environ.get('REDIS_ENDPOINT')
        redis_port = os.environ.get('REDIS_PORT')
        s3_bucket_id = os.environ.get('S3_BUCKET_ID')
        s3_bucket_arn = os.environ.get('S3_BUCKET_ARN')
        secrets_manager_api_key_arn = os.environ.get('SECRETS_MANAGER_API_KEY_ARN')
        event_bus_name = os.environ.get('EVENT_BUS_NAME')
        dynamodb_table_name = os.environ.get('DYNAMODB_TABLE_NAME')

        logger.info(f"DB Endpoint: {db_endpoint}, Port: {db_port}, Name: {db_name}")
        logger.info(f"Redis Endpoint: {redis_endpoint}, Port: {redis_port}")
        logger.info(f"S3 Bucket ID: {s3_bucket_id}, ARN: {s3_bucket_arn}")
        logger.info(f"Secrets Manager API Key ARN: {secrets_manager_api_key_arn}")
        logger.info(f"Event Bus Name: {event_bus_name}")
        logger.info(f"DynamoDB Table Name: {dynamodb_table_name}")

        # Simulate processing and publishing an event to EventBridge
        # import boto3
        # events_client = boto3.client('events')
        # events_client.put_events(
        #     Entries=[
        #         {
        #             'Source': 'custom.app',
        #             'DetailType': 'MyCustomEvent',
        #             'Detail': json.dumps({"message": "Event from Lambda", "path": path}),
        #             'EventBusName': event_bus_name
        #         }
        #     ]
        # )

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": f"Hello from Lambda! Path: {path}, Method: {method}",
                "db_info": f"{db_endpoint}:{db_port}/{db_name}",
                "redis_info": f"{redis_endpoint}:{redis_port}",
                "s3_info": f"{s3_bucket_id}",
                "dynamodb_table": f"{dynamodb_table_name}"
            })
        }
  PY
  source_content_filename = "processor.py"
  output_path             = "${path.module}/build/lambda_api_handler.zip"
}

resource "aws_lambda_function" "api_handler" {
  function_name = "${var.project_name}-${var.environment}-api-handler"
  role          = aws_iam_role.lambda_api_handler.arn
  handler       = "processor.handler"
  runtime       = var.lambda_runtime
  memory_size   = var.lambda_memory_mb
  filename      = data.archive_file.lambda_api_handler.output_path
  source_code_hash = data.archive_file.lambda_api_handler.output_base64sha256

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.networking.outputs.app_security_group_id]
  }

  environment {
    variables = {
      DB_ENDPOINT                 = data.terraform_remote_state.data.outputs.db_endpoint
      DB_PORT                     = data.terraform_remote_state.data.outputs.db_port
      DB_NAME                     = data.terraform_remote_state.data.outputs.db_name
      REDIS_ENDPOINT              = data.terraform_remote_state.data.outputs.redis_primary_endpoint
      REDIS_PORT                  = data.terraform_remote_state.data.outputs.redis_port
      S3_BUCKET_ID                = data.terraform_remote_state.data.outputs.s3_bucket_id
      S3_BUCKET_ARN               = data.terraform_remote_state.data.outputs.s3_bucket_arn
      SECRETS_MANAGER_API_KEY_ARN = aws_secretsmanager_secret.api_key.arn
      EVENT_BUS_NAME              = aws_cloudwatch_event_bus.main.name
      DYNAMODB_TABLE_NAME         = var.dynamodb_table_name # Assuming this is a direct variable
      LOG_LEVEL                   = "INFO"
    }
  }

  kms_key_arn = aws_kms_key.main.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  reserved_concurrent_executions = 100 # RULE 48
  tags                           = var.tags
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-${var.environment}-user-pool"

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  mfa_configuration = "OPTIONAL" # or "ON" for stricter
  
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # For production, use SES with "DEVELOPER"
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
  name         = "${var.project_name}-${var.environment}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity        = 30 # days maximum
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = false # Set to true if unauthenticated access is needed

  cognito_identity_providers {
    client_id             = aws_cognito_user_pool_client.main.id
    provider_name         = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
    server_side_token_check = true
  }
  tags = var.tags
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated"   = aws_iam_role.cognito_auth_role.arn
    "unauthenticated" = aws_iam_role.cognito_unauth_role.arn
  }
}

# EventBridge
resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project_name}-${var.environment}-event-bus"
  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "to_sqs" {
  name          = "${var.project_name}-${var.environment}-event-to-sqs-rule"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  event_pattern = jsonencode({
    source      = ["custom.app"]
    "detail-type" = ["MyCustomEvent"]
  })
  is_enabled = true
  tags       = var.tags
}

resource "aws_cloudwatch_event_target" "to_sqs" {
  rule          = aws_cloudwatch_event_rule.to_sqs.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  arn           = aws_sqs_queue.main.arn
  role_arn      = aws_iam_role.eventbridge_sqs.arn
}

# SQS Queue and DLQ
resource "aws_sqs_queue" "main" {
  name                       = "${var.project_name}-${var.environment}-queue"
  message_retention_seconds  = var.sqs_message_retention_days * 24 * 60 * 60
  kms_master_key_id          = aws_kms_key.main.arn
  redrive_policy             = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
  tags = var.tags
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeSendMessage"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.main.arn
      },
      {
        Sid       = "AllowLambdaSendMessage"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.lambda_api_handler.arn }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.main.arn
      }
    ]
  })
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 days (RULE 42)
  kms_master_key_id         = aws_kms_key.main.arn
  tags                      = var.tags
}

resource "aws_sqs_queue_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSQSReceiveMessage"
      Effect    = "Allow"
      Principal = { Service = "sqs.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.dlq.arn
    }]
  })
}

# Secrets Manager for API Keys
resource "aws_secretsmanager_secret" "api_key" {
  name_prefix             = "${var.project_name}-${var.environment}-api-key-"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30 # RULE 15, RULE 49
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_policy" "api_key" {
  secret_arn = aws_secretsmanager_secret.api_key.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowLambdaAccess"
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.lambda_api_handler.arn }
      Action    = "secretsmanager:GetSecretValue"
      Resource  = aws_secretsmanager_secret.api_key.arn
    }]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-api-handler-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Lambda API Handler has errors"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = aws_lambda_function.api_handler.function_name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "API Gateway 5XX errors detected"
  treat_missing_data  = "notBreaching"
  dimensions = {
    ApiName = aws_apigatewayv2_api.main.name
    Stage   = aws_apigatewayv2_stage.main.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages" {
  alarm_name          = "${var.project_name}-${var.environment}-sqs-dlq-messages-visible"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Messages in SQS Dead-Letter Queue"
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}
