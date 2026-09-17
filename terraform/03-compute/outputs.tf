output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_main_alias_arn" {
  description = "The ARN of the main KMS key alias."
  value       = aws_kms_alias.main.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS key alias for CloudWatch Logs."
  value       = aws_kms_alias.logs.name
}

output "kms_logs_alias_arn" {
  description = "The ARN of the KMS key alias for CloudWatch Logs."
  value       = aws_kms_alias.logs.arn
}

output "iam_agent_runtime_role_name" {
  description = "The name of the IAM role for AgentCore Runtime."
  value       = aws_iam_role.agent_runtime.name
}

output "iam_agent_runtime_role_arn" {
  description = "The ARN of the IAM role for AgentCore Runtime."
  value       = aws_iam_role.agent_runtime.arn
}

output "iam_gateway_role_name" {
  description = "The name of the IAM role for AgentCore Gateway."
  value       = aws_iam_role.gateway.name
}

output "iam_gateway_role_arn" {
  description = "The ARN of the IAM role for AgentCore Gateway."
  value       = aws_iam_role.gateway.arn
}

output "iam_code_interpreter_role_name" {
  description = "The name of the IAM role for AgentCore Code Interpreter."
  value       = aws_iam_role.code_interpreter.name
}

output "iam_code_interpreter_role_arn" {
  description = "The ARN of the IAM role for AgentCore Code Interpreter."
  value       = aws_iam_role.code_interpreter.arn
}

output "iam_secrets_rotation_role_name" {
  description = "The name of the IAM role for Secrets Manager rotation Lambda."
  value       = aws_iam_role.secrets_rotation.name
}

output "iam_secrets_rotation_role_arn" {
  description = "The ARN of the IAM role for Secrets Manager rotation Lambda."
  value       = aws_iam_role.secrets_rotation.arn
}

output "iam_cognito_auth_role_name" {
  description = "The name of the IAM role for Cognito Authenticated Users."
  value       = aws_iam_role.cognito_auth.name
}

output "iam_cognito_auth_role_arn" {
  description = "The ARN of the IAM role for Cognito Authenticated Users."
  value       = aws_iam_role.cognito_auth.arn
}

output "iam_cognito_unauth_role_name" {
  description = "The name of the IAM role for Cognito Unauthenticated Users."
  value       = aws_iam_role.cognito_unauth.name
}

output "iam_cognito_unauth_role_arn" {
  description = "The ARN of the IAM role for Cognito Unauthenticated Users."
  value       = aws_iam_role.cognito_unauth.arn
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_name" {
  description = "The name of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.name
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_client_name" {
  description = "The name of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.name
}

output "cognito_identity_pool_id" {
  description = "The ID of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.id
}

output "cognito_identity_pool_arn" {
  description = "The ARN of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.arn
}

output "cognito_identity_pool_name" {
  description = "The name of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.identity_pool_name
}

output "secrets_manager_third_party_api_credentials_arn" {
  description = "The ARN of the Secrets Manager secret for third-party API credentials."
  value       = aws_secretsmanager_secret.third_party_api_credentials.arn
}

output "secrets_manager_third_party_api_credentials_name" {
  description = "The name of the Secrets Manager secret for third-party API credentials."
  value       = aws_secretsmanager_secret.third_party_api_credentials.name
}

output "lambda_secrets_rotation_function_arn" {
  description = "The ARN of the Lambda function for Secrets Manager rotation."
  value       = aws_lambda_function.secrets_rotation.arn
}

output "lambda_secrets_rotation_function_name" {
  description = "The name of the Lambda function for Secrets Manager rotation."
  value       = aws_lambda_function.secrets_rotation.function_name
}

output "cloudwatch_agentcore_log_group_name" {
  description = "The name of the CloudWatch Log Group for AgentCore logs."
  value       = aws_cloudwatch_log_group.agentcore_logs.name
}

output "cloudwatch_agentcore_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for AgentCore logs."
  value       = aws_cloudwatch_log_group.agentcore_logs.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.name
}

output "bedrock_agentcore_gateway_id" {
  description = "The ID of the Bedrock AgentCore Gateway."
  value       = aws_bedrockagentcore_gateway.main.gateway_id
}

output "bedrock_agentcore_gateway_arn" {
  description = "The ARN of the Bedrock AgentCore Gateway."
  value       = aws_bedrockagentcore_gateway.main.gateway_arn
}

output "bedrock_agentcore_gateway_name" {
  description = "The name of the Bedrock AgentCore Gateway."
  value       = aws_bedrockagentcore_gateway.main.name
}

output "bedrock_agentcore_gateway_url" {
  description = "The URL of the Bedrock AgentCore Gateway."
  value       = aws_bedrockagentcore_gateway.main.gateway_url
}

output "bedrock_agentcore_runtime_id" {
  description = "The ID of the Bedrock AgentCore Runtime."
  value       = aws_bedrockagentcore_agent_runtime.main.agent_runtime_id
}

output "bedrock_agentcore_runtime_arn" {
  description = "The ARN of the Bedrock AgentCore Runtime."
  value       = aws_bedrockagentcore_agent_runtime.main.agent_runtime_arn
}

output "bedrock_agentcore_runtime_name" {
  description = "The name of the Bedrock AgentCore Runtime."
  value       = aws_bedrockagentcore_agent_runtime.main.agent_runtime_name
}

output "bedrock_agentcore_memory_id" {
  description = "The ID of the Bedrock AgentCore Memory."
  value       = aws_bedrockagentcore_memory.main.id
}

output "bedrock_agentcore_memory_arn" {
  description = "The ARN of the Bedrock AgentCore Memory."
  value       = aws_bedrockagentcore_memory.main.arn
}

output "bedrock_agentcore_memory_name" {
  description = "The name of the Bedrock AgentCore Memory."
  value       = aws_bedrockagentcore_memory.main.name
}

output "bedrock_agentcore_code_interpreter_id" {
  description = "The ID of the Bedrock AgentCore Code Interpreter."
  value       = aws_bedrockagentcore_code_interpreter.main.code_interpreter_id
}

output "bedrock_agentcore_code_interpreter_arn" {
  description = "The ARN of the Bedrock AgentCore Code Interpreter."
  value       = aws_bedrockagentcore_code_interpreter.main.code_interpreter_arn
}

output "bedrock_agentcore_code_interpreter_name" {
  description = "The name of the Bedrock AgentCore Code Interpreter."
  value       = aws_bedrockagentcore_code_interpreter.main.name
}
