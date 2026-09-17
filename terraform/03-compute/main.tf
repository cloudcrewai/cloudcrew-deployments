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

resource "random_id" "kms_main_suffix" {
  byte_length = 4
}

resource "random_id" "kms_logs_suffix" {
  byte_length = 4
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "CloudCrew AI"
  }
  # AgentCore runtime name must be alphanumeric and start with a letter, no hyphens
  agent_runtime_name_sanitized = replace(lower("${var.project_name}_${var.environment}_agent_runtime"), "/[^a-z0-9_]/", "_")
  agent_gateway_name_sanitized = replace(lower("${var.project_name}_${var.environment}_agent_gateway"), "/[^a-z0-9_]/", "_")
  agent_memory_name_sanitized  = replace(lower("${var.project_name}_${var.environment}_agent_memory"), "/[^a-z0-9_]/", "_")
  agent_code_name_sanitized    = replace(lower("${var.project_name}_${var.environment}_agent_code"), "/[^a-z0-9_]/", "_")
}

# KMS Key for general encryption (Secrets Manager, SNS)
resource "aws_kms_key" "main" {
  description             = "${var.project_name}-${var.environment}-cmk"
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
      },
      {
        Sid    = "AllowBedrockAgentCore"
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
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
  name          = "alias/${var.project_name}-${var.environment}-${random_id.kms_main_suffix.hex}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS Key for CloudWatch Logs
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
  name          = "alias/${var.project_name}-${var.environment}-logs-${random_id.kms_logs_suffix.hex}"
  target_key_id = aws_kms_key.logs.key_id
}

# IAM Role for AgentCore Runtime
resource "aws_iam_role" "agent_runtime" {
  name_prefix        = "ai-agent-platform-produ-agent-runtime-"
  description        = "Least privilege role for AgentCore Runtime"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
    }]
  })
  tags = var.tags

  inline_policy {
    name = "AgentCoreRuntimePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "bedrock:InvokeModel"
          Resource = "*" # Restrict to specific models if known
        },
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
          Resource = aws_secretsmanager_secret.third_party_api_credentials.arn
        },
        {
          Effect   = "Allow"
          Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/bedrock/${var.project_name}/${var.environment}/*"
        },
        {
          Effect   = "Allow"
          Action   = "kms:Decrypt"
          Resource = aws_kms_key.main.arn
        },
        {
          Effect   = "Allow"
          Action   = "bedrock-agentcore:InvokeAgent"
          Resource = "*" # For invoking other agents or tools
        }
      ]
    })
  }
}

# IAM Role for AgentCore Gateway
resource "aws_iam_role" "gateway" {
  name_prefix        = "${var.project_name}-${var.environment}-gateway-"
  description        = "Role for AgentCore Gateway to invoke tools"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
    }]
  })
  tags = var.tags

  inline_policy {
    name = "AgentCoreGatewayPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "bedrock-agentcore:InvokeAgent"
          Resource = aws_bedrockagentcore_agent_runtime.main.agent_runtime_arn
        },
        {
          Effect   = "Allow"
          Action   = "cognito-idp:GetPublicKey"
          Resource = aws_cognito_user_pool.main.arn
        },
        {
          Effect   = "Allow"
          Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/bedrock/${var.project_name}/${var.environment}/*"
        }
      ]
    })
  }
}

# IAM Role for AgentCore Code Interpreter
resource "aws_iam_role" "code_interpreter" {
  name_prefix        = "ai-agent-platform-pr-code-interpreter-"
  description        = "Role for AgentCore Code Interpreter"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
    }]
  })
  tags = var.tags

  inline_policy {
    name = "CodeInterpreterPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/bedrock/${var.project_name}/${var.environment}/*"
        },
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:ListBucket"] # If code interpreter needs S3 access
          Resource = "*" # Restrict to specific S3 buckets if known
        }
      ]
    })
  }
}

# IAM Role for Secrets Manager Rotation Lambda
resource "aws_iam_role" "secrets_rotation" {
  name_prefix        = "ai-agent-platform-pr-secrets-rotation-"
  description        = "Role for Secrets Manager rotation Lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_rotation_basic_execution" {
  role       = aws_iam_role.secrets_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "secrets_rotation_secrets_manager" {
  role       = aws_iam_role.secrets_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# IAM Role for Cognito Authenticated Users
resource "aws_iam_role" "cognito_auth" {
  name_prefix        = "ai-agent-platform-produc-cognito-auth-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id }
        "ForAnyValue:StringLike" = { "cognito-identity.amazonaws.com:amr" = "authenticated" }
      }
    }]
  })
  tags = var.tags

  inline_policy {
    name = "CognitoAuthenticatedPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "bedrock-agentcore:InvokeAgent"
          Resource = aws_bedrockagentcore_agent_runtime.main.agent_runtime_arn
        },
        {
          Effect   = "Allow"
          Action   = "mobileanalytics:PutEvents"
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = "cognito-sync:*"
          Resource = "arn:aws:cognito-sync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identitypool/${aws_cognito_identity_pool.main.id}"
        }
      ]
    })
  }
}

# IAM Role for Cognito Unauthenticated Users (minimal permissions)
resource "aws_iam_role" "cognito_unauth" {
  name_prefix        = "ai-agent-platform-prod-cognito-unauth-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "cognito-identity.amazonaws.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id }
        "ForAnyValue:StringLike" = { "cognito-identity.amazonaws.com:amr" = "unauthenticated" }
      }
    }]
  })
  tags = var.tags

  inline_policy {
    name = "CognitoUnauthenticatedPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "mobileanalytics:PutEvents"
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = "cognito-sync:*"
          Resource = "arn:aws:cognito-sync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identitypool/${aws_cognito_identity_pool.main.id}"
        }
      ]
    })
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name                = var.cognito_user_pool_name
  mfa_configuration   = "OPTIONAL" # Production requires OPTIONAL or ON
  deletion_protection = "ACTIVE"   # Production best practice

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # Placeholder, use SES for production
    # source_arn = "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/your-verified-email-or-domain"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = var.tags
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name                        = "${var.project_name}-${var.environment}-app-client"
  user_pool_id                = aws_cognito_user_pool.main.id
  explicit_auth_flows         = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity      = 30 # Max 30 days for production
  generate_secret             = true # For server-side applications
}

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = false # Only authenticated users for agent interaction

  cognito_identity_providers {
    client_id    = aws_cognito_user_pool_client.main.id
    provider_name = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }

  tags = var.tags
}

# Cognito Identity Pool Roles Attachment
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id
  roles = {
    "authenticated"   = aws_iam_role.cognito_auth.arn
    "unauthenticated" = aws_iam_role.cognito_unauth.arn
  }
}

# Secrets Manager Secret for Third-Party API Credentials
resource "aws_secretsmanager_secret" "third_party_api_credentials" {
  name_prefix             = "${var.project_name}-${var.environment}-third-party-api-credentials-"
  description             = "Stores sensitive API keys for external services"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 30
  tags                    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Secrets Manager Secret Policy
resource "aws_secretsmanager_secret_policy" "third_party_api_credentials" {
  secret_arn = aws_secretsmanager_secret.third_party_api_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAgentCoreRuntimeToRetrieveSecret"
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.agent_runtime.arn }
      Action    = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource  = aws_secretsmanager_secret.third_party_api_credentials.arn
    }]
  })
}

# Lambda function for Secrets Manager rotation (placeholder)
data "archive_file" "secrets_rotation_lambda" {
  type = "zip"
  source_content = <<-PY
    import json
    def lambda_handler(event, context):
        # This is a placeholder for a real rotation function.
        # A real function would implement the logic to rotate the secret.
        print(f"Rotating secret: {event['SecretId']}")
        return {"statusCode": 200, "body": json.dumps("rotation placeholder")}
  PY
  source_content_filename = "index.py"
  output_path             = "${path.module}/build/secrets_rotation.zip"
}

resource "aws_lambda_function" "secrets_rotation" {
  function_name    = "${var.project_name}-${var.environment}-secrets-rotation-lambda"
  role             = aws_iam_role.secrets_rotation.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.secrets_rotation_lambda.output_path
  source_code_hash = data.archive_file.secrets_rotation_lambda.output_base64sha256

  tracing_config {
    mode = "Active"
  }
  tags = var.tags
}

# Secrets Manager Secret Rotation
resource "aws_secretsmanager_secret_rotation" "third_party_api_credentials" {
  secret_id           = aws_secretsmanager_secret.third_party_api_credentials.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}

# CloudWatch Log Group for AgentCore components
resource "aws_cloudwatch_log_group" "agentcore_logs" {
  name              = "/bedrock/${var.project_name}/${var.environment}/agentcore"
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

# CloudWatch Alarm for AgentCore Runtime Invocations
resource "aws_cloudwatch_metric_alarm" "agentcore_runtime_invocations" {
  alarm_name          = "${var.project_name}-${var.environment}-AgentCoreRuntimeInvocations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300 # 5 minutes
  threshold           = 1000000 # Example threshold: 1 million invocations in 5 minutes
  metric_name         = "Invocations"
  namespace           = "AWS/BedrockAgentCore"
  statistic           = "Sum"
  alarm_description   = "Alarm when AgentCore Runtime invocations exceed threshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  dimensions = {
    AgentRuntimeId = aws_bedrockagentcore_agent_runtime.main.agent_runtime_id
  }
  tags = var.tags
}

# Bedrock AgentCore Gateway
resource "aws_bedrockagentcore_gateway" "main" {
  name            = local.agent_gateway_name_sanitized
  description     = "Entry point for agent interactions and tool exposure"
  role_arn        = aws_iam_role.gateway.arn
  authorizer_type = "CUSTOM_JWT"
  protocol_type   = "MCP"

  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url    = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/openid-configuration"
      allowed_audience = [aws_cognito_user_pool_client.main.id]
    }
  }

  protocol_configuration {
    mcp {
      search_type = "SEMANTIC"
    }
  }
  tags = var.tags
}

# Bedrock AgentCore Runtime
resource "aws_bedrockagentcore_agent_runtime" "main" {
  agent_runtime_name = local.agent_runtime_name_sanitized
  description        = "Orchestrates agent logic and tool execution"
  role_arn           = aws_iam_role.agent_runtime.arn

  network_configuration {
    network_mode = "PUBLIC"
  }

  agent_runtime_artifact {
    container_configuration {
      # Placeholder ECR URI. Replace with actual ECR image for agent code.
      container_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.project_name}-${var.environment}-agent:latest"
    }
  }
  tags = var.tags
}

# Bedrock AgentCore Memory
resource "aws_bedrockagentcore_memory" "main" {
  name                  = local.agent_memory_name_sanitized
  description           = "Persists conversation history"
  event_expiry_duration = 30 # 30 days
  encryption_key_arn    = aws_kms_key.main.arn
  tags                  = var.tags
}

# Bedrock AgentCore Memory Strategy (Semantic)
resource "aws_bedrockagentcore_memory_strategy" "semantic" {
  memory_id           = aws_bedrockagentcore_memory.main.id
  name                = "semantic_recall"
  type                = "SEMANTIC"
  namespace_templates = ["/agentcore/${var.project_name}/${var.environment}/{sessionId}"]
}

# Bedrock AgentCore Code Interpreter
resource "aws_bedrockagentcore_code_interpreter" "main" {
  name               = local.agent_code_name_sanitized
  description        = "Handles data analysis tasks for the agent"
  execution_role_arn = aws_iam_role.code_interpreter.arn

  network_configuration {
    network_mode = "PUBLIC"
  }
  tags = var.tags
}
