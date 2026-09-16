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

output "cloudwatch_log_group_api_gateway_name" {
  description = "The name of the CloudWatch Log Group for API Gateway."
  value       = aws_cloudwatch_log_group.api_gateway.name
}

output "cloudwatch_log_group_api_gateway_arn" {
  description = "The ARN of the CloudWatch Log Group for API Gateway."
  value       = aws_cloudwatch_log_group.api_gateway.arn
}

output "cloudwatch_log_group_lambda_api_handler_name" {
  description = "The name of the CloudWatch Log Group for the API handler Lambda."
  value       = aws_cloudwatch_log_group.lambda_api_handler.name
}

output "cloudwatch_log_group_lambda_async_processor_name" {
  description = "The name of the CloudWatch Log Group for the async processor Lambda."
  value       = aws_cloudwatch_log_group.lambda_async_processor.name
}

output "cloudwatch_log_group_eventbridge_name" {
  description = "The name of the CloudWatch Log Group for EventBridge."
  value       = aws_cloudwatch_log_group.eventbridge.name
}

output "cloudwatch_log_group_sqs_dlq_name" {
  description = "The name of the CloudWatch Log Group for the SQS DLQ."
  value       = aws_cloudwatch_log_group.sqs_dlq.name
}

output "cloudwatch_log_group_alarms_name" {
  description = "The name of the CloudWatch Log Group for alarms."
  value       = aws_cloudwatch_log_group.alarms.name
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.name
}

output "iam_role_lambda_api_handler_arn" {
  description = "The ARN of the IAM role for the API handler Lambda."
  value       = aws_iam_role.lambda_api_handler.arn
}

output "iam_role_lambda_async_processor_arn" {
  description = "The ARN of the IAM role for the async processor Lambda."
  value       = aws_iam_role.lambda_async_processor.arn
}

output "iam_role_api_gateway_lambda_invoke_arn" {
  description = "The ARN of the IAM role for API Gateway to invoke Lambda."
  value       = aws_iam_role.api_gateway_lambda_invoke.arn
}

output "iam_role_eventbridge_sqs_send_arn" {
  description = "The ARN of the IAM role for EventBridge to send messages to SQS."
  value       = aws_iam_role.eventbridge_sqs_send.arn
}

output "iam_role_secrets_rotation_lambda_arn" {
  description = "The ARN of the IAM role for the Secrets Manager rotation Lambda."
  value       = aws_iam_role.secrets_rotation_lambda.arn
}

output "iam_role_cognito_auth_role_arn" {
  description = "The ARN of the IAM role for authenticated Cognito users."
  value       = aws_iam_role.cognito_auth_role.arn
}

output "iam_role_cognito_unauth_role_arn" {
  description = "The ARN of the IAM role for unauthenticated Cognito users."
  value       = aws_iam_role.cognito_unauth_role.arn
}

output "iam_role_route53_acm_validation_arn" {
  description = "The ARN of the IAM role for Route53 ACM validation."
  value       = aws_iam_role.route53_acm_validation.arn
}

output "security_group_lambda_id" {
  description = "The ID of the security group for Lambda functions."
  value       = aws_security_group.lambda.id
}

output "security_group_lambda_name" {
  description = "The name of the security group for Lambda functions."
  value       = aws_security_group.lambda.name
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_sqs_id" {
  description = "The ID of the VPC endpoint for SQS."
  value       = aws_vpc_endpoint.sqs.id
}

output "vpc_endpoint_events_id" {
  description = "The ID of the VPC endpoint for EventBridge."
  value       = aws_vpc_endpoint.events.id
}

output "vpc_endpoint_logs_id" {
  description = "The ID of the VPC endpoint for CloudWatch Logs."
  value       = aws_vpc_endpoint.logs.id
}

output "vpc_endpoint_kms_id" {
  description = "The ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "sqs_dlq_arn" {
  description = "The ARN of the SQS Dead-Letter Queue."
  value       = aws_sqs_queue.sqs_dlq.arn
}

output "sqs_dlq_url" {
  description = "The URL of the SQS Dead-Letter Queue."
  value       = aws_sqs_queue.sqs_dlq.url
}

output "sqs_main_queue_arn" {
  description = "The ARN of the main SQS queue."
  value       = aws_sqs_queue.sqs_main_queue.arn
}

output "sqs_main_queue_url" {
  description = "The URL of the main SQS queue."
  value       = aws_sqs_queue.sqs_main_queue.url
}

output "lambda_api_handler_function_name" {
  description = "The name of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.function_name
}

output "lambda_api_handler_arn" {
  description = "The ARN of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.arn
}

output "lambda_api_handler_invoke_arn" {
  description = "The invoke ARN of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.invoke_arn
}

output "lambda_async_processor_function_name" {
  description = "The name of the async processor Lambda function."
  value       = aws_lambda_function.lambda_async_processor.function_name
}

output "lambda_async_processor_arn" {
  description = "The ARN of the async processor Lambda function."
  value       = aws_lambda_function.lambda_async_processor.arn
}

output "lambda_secrets_rotation_function_name" {
  description = "The name of the Secrets Manager rotation Lambda function."
  value       = aws_lambda_function.secrets_rotation.function_name
}

output "lambda_secrets_rotation_arn" {
  description = "The ARN of the Secrets Manager rotation Lambda function."
  value       = aws_lambda_function.secrets_rotation.arn
}

output "secretsmanager_main_arn" {
  description = "The ARN of the main Secrets Manager secret."
  value       = aws_secretsmanager_secret.main.arn
}

output "secretsmanager_main_name" {
  description = "The name of the main Secrets Manager secret."
  value       = aws_secretsmanager_secret.main.name
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_client_secret" {
  description = "The secret of the Cognito User Pool Client (for server-side apps)."
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}

output "cognito_identity_pool_id" {
  description = "The ID of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.id
}

output "apigatewayv2_api_id" {
  description = "The ID of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.main.id
}

output "apigatewayv2_api_endpoint" {
  description = "The default endpoint of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "apigatewayv2_api_execution_arn" {
  description = "The execution ARN of the API Gateway HTTP API."
  value       = aws_apigatewayv2_api.main.execution_arn
}

output "apigatewayv2_stage_invoke_url" {
  description = "The invoke URL of the API Gateway HTTP API stage."
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the custom domain."
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_name" {
  description = "The domain name of the ACM certificate."
  value       = aws_acm_certificate.main.domain_name
}

output "route53_hosted_zone_id" {
  description = "The ID of the Route53 hosted zone."
  value       = aws_route53_zone.main.zone_id
}

output "route53_hosted_zone_name" {
  description = "The name of the Route53 hosted zone."
  value       = aws_route53_zone.main.name
}

output "apigatewayv2_custom_domain_name" {
  description = "The custom domain name for API Gateway."
  value       = aws_apigatewayv2_domain_name.main.domain_name
}

output "apigatewayv2_custom_domain_target_domain_name" {
  description = "The target domain name for the API Gateway custom domain (for CNAME/ALIAS record)."
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "apigatewayv2_custom_domain_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID for the API Gateway custom domain."
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].hosted_zone_id
}

output "eventbridge_sqs_target_rule_name" {
  description = "The name of the EventBridge rule routing events to SQS."
  value       = aws_cloudwatch_event_rule.sqs_target.name
}
