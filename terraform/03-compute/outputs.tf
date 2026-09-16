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

output "cloudwatch_log_group_api_gateway_access_logs_name" {
  description = "The name of the CloudWatch Log Group for API Gateway access logs."
  value       = aws_cloudwatch_log_group.api_gateway_access_logs.name
}

output "cloudwatch_log_group_api_gateway_access_logs_arn" {
  description = "The ARN of the CloudWatch Log Group for API Gateway access logs."
  value       = aws_cloudwatch_log_group.api_gateway_access_logs.arn
}

output "cloudwatch_log_group_lambda_api_handler_name" {
  description = "The name of the CloudWatch Log Group for the Lambda API handler."
  value       = aws_cloudwatch_log_group.lambda_api_handler.name
}

output "cloudwatch_log_group_lambda_api_handler_arn" {
  description = "The ARN of the CloudWatch Log Group for the Lambda API handler."
  value       = aws_cloudwatch_log_group.lambda_api_handler.arn
}

output "cloudwatch_log_group_sqs_dlq_alarms_name" {
  description = "The name of the CloudWatch Log Group for SQS DLQ alarms."
  value       = aws_cloudwatch_log_group.sqs_dlq_alarms.name
}

output "cloudwatch_log_group_sqs_dlq_alarms_arn" {
  description = "The ARN of the CloudWatch Log Group for SQS DLQ alarms."
  value       = aws_cloudwatch_log_group.sqs_dlq_alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.name
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "iam_lambda_api_handler_role_arn" {
  description = "The ARN of the IAM role for the Lambda API handler."
  value       = aws_iam_role.lambda_api_handler.arn
}

output "iam_lambda_api_handler_role_name" {
  description = "The name of the IAM role for the Lambda API handler."
  value       = aws_iam_role.lambda_api_handler.name
}

output "iam_api_gateway_lambda_invoke_role_arn" {
  description = "The ARN of the IAM role for API Gateway to invoke Lambda."
  value       = aws_iam_role.api_gateway_lambda_invoke.arn
}

output "iam_api_gateway_lambda_invoke_role_name" {
  description = "The name of the IAM role for API Gateway to invoke Lambda."
  value       = aws_iam_role.api_gateway_lambda_invoke.name
}

output "iam_eventbridge_sqs_role_arn" {
  description = "The ARN of the IAM role for EventBridge to send messages to SQS."
  value       = aws_iam_role.eventbridge_sqs.arn
}

output "iam_eventbridge_sqs_role_name" {
  description = "The name of the IAM role for EventBridge to send messages to SQS."
  value       = aws_iam_role.eventbridge_sqs.name
}

output "iam_cognito_auth_role_arn" {
  description = "The ARN of the IAM role for Cognito authenticated users."
  value       = aws_iam_role.cognito_auth_role.arn
}

output "iam_cognito_auth_role_name" {
  description = "The name of the IAM role for Cognito authenticated users."
  value       = aws_iam_role.cognito_auth_role.name
}

output "iam_cognito_unauth_role_arn" {
  description = "The ARN of the IAM role for Cognito unauthenticated users."
  value       = aws_iam_role.cognito_unauth_role.arn
}

output "iam_cognito_unauth_role_name" {
  description = "The name of the IAM role for Cognito unauthenticated users."
  value       = aws_iam_role.cognito_unauth_role.name
}

output "iam_cloudwatch_alarms_role_arn" {
  description = "The ARN of the IAM role for CloudWatch Alarms to publish to SNS."
  value       = aws_iam_role.cloudwatch_alarms.arn
}

output "iam_cloudwatch_alarms_role_name" {
  description = "The name of the IAM role for CloudWatch Alarms to publish to SNS."
  value       = aws_iam_role.cloudwatch_alarms.name
}

output "acm_api_domain_certificate_arn" {
  description = "The ARN of the ACM certificate for the API custom domain."
  value       = aws_acm_certificate.api_domain.arn
}

output "acm_api_domain_certificate_domain_name" {
  description = "The domain name of the ACM certificate for the API custom domain."
  value       = aws_acm_certificate.api_domain.domain_name
}

output "api_gateway_id" {
  description = "The ID of the HTTP API Gateway."
  value       = aws_apigatewayv2_api.main.id
}

output "api_gateway_endpoint" {
  description = "The default endpoint of the HTTP API Gateway."
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_gateway_custom_domain_name" {
  description = "The custom domain name configured for the API Gateway."
  value       = aws_apigatewayv2_domain_name.main.domain_name
}

output "api_gateway_custom_domain_target_domain_name" {
  description = "The target domain name for the API Gateway custom domain (for CNAME record)."
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "api_gateway_stage_name" {
  description = "The name of the API Gateway stage."
  value       = aws_apigatewayv2_stage.main.name
}

output "api_gateway_stage_invoke_url" {
  description = "The invoke URL of the API Gateway stage."
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "lambda_api_handler_function_name" {
  description = "The name of the Lambda API handler function."
  value       = aws_lambda_function.api_handler.function_name
}

output "lambda_api_handler_function_arn" {
  description = "The ARN of the Lambda API handler function."
  value       = aws_lambda_function.api_handler.arn
}

output "lambda_api_handler_invoke_arn" {
  description = "The invoke ARN of the Lambda API handler function."
  value       = aws_lambda_function.api_handler.invoke_arn
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_endpoint" {
  description = "The endpoint for the Cognito User Pool."
  value       = "cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_identity_pool_id" {
  description = "The ID of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.id
}

output "eventbridge_bus_name" {
  description = "The name of the EventBridge event bus."
  value       = aws_cloudwatch_event_bus.main.name
}

output "eventbridge_bus_arn" {
  description = "The ARN of the EventBridge event bus."
  value       = aws_cloudwatch_event_bus.main.arn
}

output "sqs_main_queue_id" {
  description = "The ID of the main SQS queue."
  value       = aws_sqs_queue.main.id
}

output "sqs_main_queue_arn" {
  description = "The ARN of the main SQS queue."
  value       = aws_sqs_queue.main.arn
}

output "sqs_main_queue_url" {
  description = "The URL of the main SQS queue."
  value       = aws_sqs_queue.main.url
}

output "sqs_dlq_queue_id" {
  description = "The ID of the SQS Dead-Letter Queue (DLQ)."
  value       = aws_sqs_queue.dlq.id
}

output "sqs_dlq_queue_arn" {
  description = "The ARN of the SQS Dead-Letter Queue (DLQ)."
  value       = aws_sqs_queue.dlq.arn
}

output "sqs_dlq_queue_url" {
  description = "The URL of the SQS Dead-Letter Queue (DLQ)."
  value       = aws_sqs_queue.dlq.url
}

output "secrets_manager_api_key_arn" {
  description = "The ARN of the Secrets Manager secret for API keys."
  value       = aws_secretsmanager_secret.api_key.arn
}

output "secrets_manager_api_key_name" {
  description = "The name of the Secrets Manager secret for API keys."
  value       = aws_secretsmanager_secret.api_key.name
}
