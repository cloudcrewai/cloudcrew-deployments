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

output "kms_cloudtrail_key_id" {
  description = "The ID of the KMS key for CloudTrail."
  value       = aws_kms_key.cloudtrail.key_id
}

output "kms_cloudtrail_key_arn" {
  description = "The ARN of the KMS key for CloudTrail."
  value       = aws_kms_key.cloudtrail.arn
}

output "kms_cloudtrail_alias_name" {
  description = "The name of the KMS key alias for CloudTrail."
  value       = aws_kms_alias.cloudtrail.name
}

output "kms_config_key_id" {
  description = "The ID of the KMS key for AWS Config."
  value       = aws_kms_key.config.key_id
}

output "kms_config_key_arn" {
  description = "The ARN of the KMS key for AWS Config."
  value       = aws_kms_key.config.arn
}

output "kms_config_alias_name" {
  description = "The name of the KMS key alias for AWS Config."
  value       = aws_kms_alias.config.name
}

output "lambda_api_handler_role_arn" {
  description = "ARN of the IAM role for the API handler Lambda function."
  value       = aws_iam_role.lambda_api_handler.arn
}

output "lambda_async_processor_role_arn" {
  description = "ARN of the IAM role for the async processor Lambda function."
  value       = aws_iam_role.lambda_async_processor.arn
}

output "secrets_manager_rotation_role_arn" {
  description = "ARN of the IAM role for the Secrets Manager rotation Lambda function."
  value       = aws_iam_role.secrets_manager_rotation.arn
}

output "eventbridge_to_sqs_role_arn" {
  description = "ARN of the IAM role for EventBridge to SQS."
  value       = aws_iam_role.eventbridge_to_sqs.arn
}

output "cloudtrail_role_arn" {
  description = "ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "config_role_arn" {
  description = "ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "cognito_unauthenticated_role_arn" {
  description = "ARN of the IAM role for unauthenticated Cognito users."
  value       = aws_iam_role.cognito_unauthenticated.arn
}

output "cognito_authenticated_role_arn" {
  description = "ARN of the IAM role for authenticated Cognito users."
  value       = aws_iam_role.cognito_authenticated.arn
}

output "sns_publish_role_arn" {
  description = "ARN of the IAM role for SNS publishing (e.g., CloudWatch alarms)."
  value       = aws_iam_role.sns_publish.arn
}

output "cloudwatch_log_group_api_gateway_name" {
  description = "Name of the CloudWatch Log Group for API Gateway."
  value       = aws_cloudwatch_log_group.api_gateway.name
}

output "cloudwatch_log_group_lambda_api_handler_name" {
  description = "Name of the CloudWatch Log Group for the API handler Lambda."
  value       = aws_cloudwatch_log_group.lambda_api_handler.name
}

output "cloudwatch_log_group_lambda_async_processor_name" {
  description = "Name of the CloudWatch Log Group for the async processor Lambda."
  value       = aws_cloudwatch_log_group.lambda_async_processor.name
}

output "cloudwatch_log_group_secrets_manager_rotation_name" {
  description = "Name of the CloudWatch Log Group for Secrets Manager rotation Lambda."
  value       = aws_cloudwatch_log_group.secrets_manager_rotation.name
}

output "cloudwatch_log_group_cloudtrail_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_config_name" {
  description = "Name of the CloudWatch Log Group for AWS Config."
  value       = aws_cloudwatch_log_group.config.name
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.name
}

output "sns_config_notifications_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "sns_config_notifications_topic_name" {
  description = "Name of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.name
}

output "route53_hosted_zone_id" {
  description = "ID of the Route53 hosted zone."
  value       = aws_route53_zone.main.zone_id
}

output "route53_hosted_zone_name" {
  description = "Name of the Route53 hosted zone."
  value       = aws_route53_zone.main.name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = aws_acm_certificate.main.arn
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool."
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_client_id" {
  description = "ID of the Cognito User Pool Client."
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_identity_pool_id" {
  description = "ID of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.id
}

output "cognito_identity_pool_arn" {
  description = "ARN of the Cognito Identity Pool."
  value       = aws_cognito_identity_pool.main.arn
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group for VPC endpoints."
  value       = aws_security_group.vpc_endpoint.id
}

output "apigatewayv2_api_id" {
  description = "ID of the API Gateway v2 HTTP API."
  value       = aws_apigatewayv2_api.main.id
}

output "apigatewayv2_api_endpoint" {
  description = "The API Gateway v2 HTTP API endpoint."
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "apigatewayv2_domain_name" {
  description = "The custom domain name for API Gateway v2."
  value       = aws_apigatewayv2_domain_name.main.domain_name
}

output "apigatewayv2_domain_name_target_domain_name" {
  description = "The target domain name for the API Gateway v2 custom domain."
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "apigatewayv2_stage_name" {
  description = "Name of the API Gateway v2 stage."
  value       = aws_apigatewayv2_stage.main.name
}

output "lambda_api_handler_function_name" {
  description = "Name of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.function_name
}

output "lambda_api_handler_function_arn" {
  description = "ARN of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.arn
}

output "lambda_api_handler_invoke_arn" {
  description = "Invoke ARN of the API handler Lambda function."
  value       = aws_lambda_function.lambda_api_handler.invoke_arn
}

output "lambda_async_processor_function_name" {
  description = "Name of the async processor Lambda function."
  value       = aws_lambda_function.lambda_async_processor.function_name
}

output "lambda_async_processor_function_arn" {
  description = "ARN of the async processor Lambda function."
  value       = aws_lambda_function.lambda_async_processor.arn
}

output "lambda_async_processor_invoke_arn" {
  description = "Invoke ARN of the async processor Lambda function."
  value       = aws_lambda_function.lambda_async_processor.invoke_arn
}

output "sqs_main_queue_name" {
  description = "Name of the main SQS queue."
  value       = aws_sqs_queue.sqs_main_queue.name
}

output "sqs_main_queue_url" {
  description = "URL of the main SQS queue."
  value       = aws_sqs_queue.sqs_main_queue.url
}

output "sqs_main_queue_arn" {
  description = "ARN of the main SQS queue."
  value       = aws_sqs_queue.sqs_main_queue.arn
}

output "sqs_dlq_name" {
  description = "Name of the SQS Dead Letter Queue."
  value       = aws_sqs_queue.sqs_dlq.name
}

output "sqs_dlq_url" {
  description = "URL of the SQS Dead Letter Queue."
  value       = aws_sqs_queue.sqs_dlq.url
}

output "sqs_dlq_arn" {
  description = "ARN of the SQS Dead Letter Queue."
  value       = aws_sqs_queue.sqs_dlq.arn
}

output "eventbridge_sqs_event_rule_name" {
  description = "Name of the EventBridge rule for SQS."
  value       = aws_cloudwatch_event_rule.sqs_event_rule.name
}

output "eventbridge_sqs_event_rule_arn" {
  description = "ARN of the EventBridge rule for SQS."
  value       = aws_cloudwatch_event_rule.sqs_event_rule.arn
}

output "secretsmanager_third_party_api_keys_arn" {
  description = "ARN of the Secrets Manager secret for third-party API keys."
  value       = aws_secretsmanager_secret.third_party_api_keys.arn
}

output "secretsmanager_third_party_api_keys_name" {
  description = "Name of the Secrets Manager secret for third-party API keys."
  value       = aws_secretsmanager_secret.third_party_api_keys.name
}

output "secrets_rotation_lambda_function_name" {
  description = "Name of the Secrets Manager rotation Lambda function."
  value       = aws_lambda_function.secrets_rotation_lambda.function_name
}

output "secrets_rotation_lambda_function_arn" {
  description = "ARN of the Secrets Manager rotation Lambda function."
  value       = aws_lambda_function.secrets_rotation_lambda.arn
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_main_arn" {
  description = "ARN of the main CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector."
  value       = aws_guardduty_detector.main.arn
}

output "securityhub_account_id" {
  description = "ID of the Security Hub account resource."
  value       = aws_securityhub_account.main.id
}

output "s3_config_logs_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "s3_config_logs_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.main.name
}
