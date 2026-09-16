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

# KMS Key for general encryption (Secrets Manager, SQS, SNS)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-general-cmk"
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
        Sid    = "AllowLambdaUseOfKey"
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
        Sid    = "AllowSQSUseOfKey"
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
      },
      {
        Sid    = "AllowSNSUseOfKey"
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
  tags = var.tags
}

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-general-${random_id.kms_main_suffix.hex}"
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
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
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

resource "aws_cloudwatch_log_group" "eventbridge" {
  name              = "/aws/events/${var.project_name}-${var.environment}-bus"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "sqs_dlq" {
  name              = "/aws/sqs/${var.project_name}-${var.environment}-dlq"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "alarms" {
  name              = "/${var.project_name}/${var.environment}/alarms"
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

# IAM Roles
resource "aws_iam_role" "lambda_api_handler" {
  name_prefix = "production-serverles-api-handler-role-"
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

resource "aws_iam_role_policy" "lambda_api_handler_permissions" {
  name = "${var.project_name}-${var.environment}-api-handler-policy"
  role = aws_iam_role.lambda_api_handler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = data.terraform_remote_state.data.outputs.db_secret_arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem"]
        Resource = "${data.terraform_remote_state.data.outputs.s3_bucket_arn}/*" # Assuming DynamoDB table ARN is similar to S3 bucket ARN for now
      },
      {
        Effect   = "Allow"
        Action   = "events:PutEvents"
        Resource = "*" # EventBridge default bus
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

resource "aws_iam_role" "lambda_async_processor" {
  name_prefix = "production-serve-async-processor-role-"
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

resource "aws_iam_role_policy" "lambda_async_processor_permissions" {
  name = "${var.project_name}-${var.environment}-async-processor-policy"
  role = aws_iam_role.lambda_async_processor.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.sqs_main_queue.arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

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
      Resource = aws_lambda_function.lambda_api_handler.arn
    }]
  })
}

resource "aws_iam_role" "eventbridge_sqs_send" {
  name_prefix = "production-eventbridge-sqs-send-role-"
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

resource "aws_iam_role_policy" "eventbridge_sqs_send" {
  name = "${var.project_name}-${var.environment}-eventbridge-sqs-send-policy"
  role = aws_iam_role.eventbridge_sqs_send.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sqs:SendMessage"
      Effect   = "Allow"
      Resource = aws_sqs_queue.sqs_main_queue.arn
    }]
  })
}

resource "aws_iam_role" "secrets_rotation_lambda" {
  name_prefix = "production-serv-secrets-rotation-role-"
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
  role       = aws_iam_role.secrets_rotation_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "secrets_rotation_lambda_permissions" {
  name = "${var.project_name}-${var.environment}-secrets-rotation-policy"
  role = aws_iam_role.secrets_rotation_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.main.arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

resource "aws_iam_role" "cognito_auth_role" {
  name_prefix = "production-serverle-cognito-auth-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
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

resource "aws_iam_role_policy" "cognito_auth_role_policy" {
  name = "${var.project_name}-${var.environment}-cognito-auth-policy"
  role = aws_iam_role.cognito_auth_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["mobileanalytics:PutEvents", "cognito-sync:"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "cognito_unauth_role" {
  name_prefix = "production-server-cognito-unauth-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRoleWithWebIdentity"
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

resource "aws_iam_role_policy" "cognito_unauth_role_policy" {
  name = "${var.project_name}-${var.environment}-cognito-unauth-policy"
  role = aws_iam_role.cognito_unauth_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["mobileanalytics:PutEvents", "cognito-sync:"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "route53_acm_validation" {
  name_prefix = "productio-route53-acm-validation-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "acm.amazonaws.com" }
    }]
  })
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "route53_acm_validation" {
  name = "${var.project_name}-${var.environment}-route53-acm-validation-policy"
  role = aws_iam_role.route53_acm_validation.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["route53:GetChange", "route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets"]
      Resource = aws_route53_zone.main.arn
    }]
  })
}

# Security Group for Lambda functions
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security group for Lambda functions in VPC"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  tags        = var.tags

  # Egress rules for Lambda to access other services
  egress {
    description = "Allow outbound to Secrets Manager VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
  egress {
    description = "Allow outbound to SQS VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
  egress {
    description = "Allow outbound to EventBridge VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
  egress {
    description = "Allow outbound to CloudWatch Logs VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
  egress {
    description = "Allow outbound to KMS VPC Endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
  egress {
    description = "Allow outbound to DynamoDB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.networking.outputs.vpc_cidr_block
  }
}

# VPC Interface Endpoints for AWS Services
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  private_dns_enabled = true
  tags = var.tags
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  private_dns_enabled = true
  tags = var.tags
}

resource "aws_vpc_endpoint" "events" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.events"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  private_dns_enabled = true
  tags = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  private_dns_enabled = true
  tags = var.tags
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = data.terraform_remote_state.networking.outputs.vpc_id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  private_dns_enabled = true
  tags = var.tags
}

# SQS Queues
resource "aws_sqs_queue" "sqs_dlq" {
  name                      = "${var.project_name}-${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = aws_kms_key.main.arn
  tags                      = var.tags
}

resource "aws_sqs_queue" "sqs_main_queue" {
  name                      = "${var.project_name}-${var.environment}-main-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30
  kms_master_key_id         = aws_kms_key.main.arn
  redrive_policy            = "{\"deadLetterTargetArn\": \"${aws_sqs_queue.sqs_dlq.arn}\", \"maxReceiveCount\": 5}"
  tags                      = var.tags
}

resource "aws_sqs_queue_policy" "sqs_main_queue_eventbridge_access" {
  queue_url = aws_sqs_queue.sqs_main_queue.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.sqs_main_queue.arn
    }]
  })
}

# Lambda Functions
data "archive_file" "lambda_api_handler" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3

    secrets_client = boto3.client('secretsmanager')
    dynamodb_client = boto3.client('dynamodb')
    eventbridge_client = boto3.client('events')

    def handler(event, context):
        try:
            # Example: Retrieve secret
            secret_arn = os.environ.get('THIRD_PARTY_API_KEY_ARN')
            if secret_arn:
                secret_response = secrets_client.get_secret_value(SecretId=secret_arn)
                api_key = secret_response['SecretString']
                print(f"Retrieved API Key: {api_key[:5]}...") # Log first 5 chars for debug

            # Example: Interact with DynamoDB (assuming table name from env var)
            table_name = os.environ.get('DYNAMODB_TABLE_NAME')
            if table_name:
                dynamodb_client.put_item(TableName=table_name, Item={'id': {'S': '123'}, 'data': {'S': 'hello'}})
                print("Put item to DynamoDB")

            # Example: Publish event to EventBridge
            eventbridge_client.put_events(
                Entries=[
                    {
                        'Source': 'custom.app',
                        'DetailType': 'MyCustomEvent',
                        'Detail': json.dumps({'message': 'Event from API handler'}),
                        'EventBusName': 'default'
                    }
                ]
            )
            print("Published event to EventBridge")

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "API handler processed request successfully!"})
            }
        except Exception as e:
            print(f"Error in API handler: {e}")
            return {
                "statusCode": 500,
                "body": json.dumps({"message": f"Internal server error: {str(e)}"})
            }
  PY
  source_content_filename = "app.py"
  output_path             = "${path.module}/build/lambda_api_handler.zip"
}

resource "aws_lambda_function" "lambda_api_handler" {
  function_name    = "${var.project_name}-${var.environment}-api-handler"
  role             = aws_iam_role.lambda_api_handler.arn
  handler          = "app.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_api_handler.output_path
  source_code_hash = data.archive_file.lambda_api_handler.output_base64sha256
  memory_size      = 512
  timeout          = 30

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      THIRD_PARTY_API_KEY_ARN = aws_secretsmanager_secret.main.arn
      DYNAMODB_TABLE_NAME     = "your-dynamodb-table-name" # Placeholder, assuming DynamoDB is in data phase
    }
  }

  kms_key_arn = aws_kms_key.main.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.sqs_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  reserved_concurrent_executions = 100
  tags                           = var.tags
}

resource "aws_lambda_permission" "api_gateway_to_lambda_api_handler" {
  statement_id  = "AllowAPIGatewayInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

data "archive_file" "lambda_async_processor" {
  type = "zip"
  source_content = <<-PY
    import json
    import os
    import boto3

    sqs_client = boto3.client('sqs')

    def handler(event, context):
        for record in event['Records']:
            body = json.loads(record['body'])
            print(f"Processing message: {body}")
            # Simulate processing
            if 'fail' in body and body['fail']:
                raise Exception("Simulated processing failure")
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Async processor processed messages successfully!"})
        }
  PY
  source_content_filename = "processor.py"
  output_path             = "${path.module}/build/lambda_async_processor.zip"
}

resource "aws_lambda_function" "lambda_async_processor" {
  function_name    = "${var.project_name}-${var.environment}-async-processor"
  role             = aws_iam_role.lambda_async_processor.arn
  handler          = "processor.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_async_processor.output_path
  source_code_hash = data.archive_file.lambda_async_processor.output_base64sha256
  memory_size      = 256
  timeout          = 60

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  kms_key_arn = aws_kms_key.main.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.sqs_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  reserved_concurrent_executions = 50
  tags                           = var.tags
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_async_processor" {
  event_source_arn = aws_sqs_queue.sqs_main_queue.arn
  function_name    = aws_lambda_function.lambda_async_processor.arn
  batch_size       = 10
  enabled          = true
}

# Secrets Manager
resource "aws_secretsmanager_secret" "main" {
  name_prefix             = "${var.project_name}-${var.environment}-third-party-api-keys-"
  description             = "Third-party API keys"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "secrets_rotation" {
  type = "zip"
  source_content = <<-PY
    import json
    def lambda_handler(event, context):
        # This is a placeholder for a real rotation function.
        # In a real scenario, this function would connect to the third-party service,
        # generate new credentials, update the secret, and then update the service.
        print(f"Secrets Manager rotation event: {json.dumps(event)}")
        return {"statusCode": 200, "body": json.dumps("rotation placeholder")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/secrets_rotation.zip"
}

resource "aws_lambda_function" "secrets_rotation" {
  function_name    = "${var.project_name}-${var.environment}-secrets-rotation"
  role             = aws_iam_role.secrets_rotation_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.secrets_rotation.output_path
  source_code_hash = data.archive_file.secrets_rotation.output_base64sha256
  memory_size      = 128
  timeout          = 60

  kms_key_arn = aws_kms_key.main.arn

  tracing_config {
    mode = "Active"
  }
  tags = var.tags
}

resource "aws_secretsmanager_secret_rotation" "main" {
  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name                      = "${var.project_name}-${var.environment}-api-users"
  mfa_configuration         = "OPTIONAL"
  auto_verified_attributes  = ["email"]
  deletion_protection       = "ACTIVE"
  email_verification_message = "The verification code to your new account is {####}"
  email_verification_subject = "Verify your email for ${var.project_name}"

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # Use SES for production if available
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "main" {
  name                          = "${var.project_name}-${var.environment}-app-client"
  user_pool_id                  = aws_cognito_user_pool.main.id
  explicit_auth_flows           = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity        = 30
  generate_secret               = true # For server-side applications
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id             = aws_cognito_user_pool_client.main.id
    provider_name         = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
    server_side_token_check = false
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

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  tags          = var.tags
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
      integration_error_message = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
    data_trace_enabled     = true
    detailed_metrics_enabled = true
    logging_level          = "INFO"
  }
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_api_handler" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.lambda_api_handler.invoke_arn
  payload_format_version = "2.0"
  credentials_arn    = aws_iam_role.api_gateway_lambda_invoke.arn
  timeout_milliseconds = 29000 # Max 29 seconds for HTTP API
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  name             = "${var.project_name}-${var.environment}-cognito-authorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.main.id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

resource "aws_apigatewayv2_route" "default" {
  api_id        = aws_apigatewayv2_api.main.id
  route_key     = "ANY /{proxy+}"
  target        = "integrations/${aws_apigatewayv2_integration.lambda_api_handler.id}"
  authorization_type = "JWT" # Use JWT for authenticated routes
  authorizer_id = aws_apigatewayv2_authorizer.cognito.id
}

# Custom Domain for API Gateway
resource "aws_acm_certificate" "main" {
  domain_name       = var.api_gateway_custom_domain
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "main" {
  name = var.hosted_zone_name
  tags = var.tags
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
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
  stage       = aws_apigatewayv2_stage.main.name
}

resource "aws_route53_record" "api_gateway_cname" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.api_gateway_custom_domain
  type    = "A"
  alias {
    name                   = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}

# EventBridge
resource "aws_cloudwatch_event_rule" "sqs_target" {
  name          = "${var.project_name}-${var.environment}-event-to-sqs-rule"
  event_bus_name = "default"
  event_pattern = jsonencode({
    source      = ["custom.app"]
    detail-type = ["MyCustomEvent"]
  })
  description = "Routes custom events to SQS main queue"
  tags        = var.tags
}

resource "aws_cloudwatch_event_target" "sqs_main_queue" {
  rule      = aws_cloudwatch_event_rule.sqs_target.name
  arn       = aws_sqs_queue.sqs_main_queue.arn
  role_arn  = aws_iam_role.eventbridge_sqs_send.arn
  event_bus_name = "default"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_api_handler_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-api-handler-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Lambda API Handler has errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.lambda_api_handler.function_name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_api_handler_throttles" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-api-handler-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Lambda API Handler is throttled"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.lambda_api_handler.function_name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_async_processor_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-async-processor-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when Lambda Async Processor has errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    FunctionName = aws_lambda_function.lambda_async_processor.function_name
  }
  tags = var.tags
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
  alarm_description   = "Alarm when messages appear in SQS Dead-Letter Queue"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    QueueName = aws_sqs_queue.sqs_dlq.name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-apigw-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when API Gateway 5XX errors occur"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    ApiName = aws_apigatewayv2_api.main.name
    Stage   = aws_apigatewayv2_stage.main.name
  }
  tags = var.tags
}
