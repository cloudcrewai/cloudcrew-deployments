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
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
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

output "lambda_iam_role_arn" {
  description = "The ARN of the IAM role for the Lambda stream processor."
  value       = aws_iam_role.lambda.arn
}

output "lambda_iam_role_name" {
  description = "The name of the IAM role for the Lambda stream processor."
  value       = aws_iam_role.lambda.name
}

output "iot_rule_iam_role_arn" {
  description = "The ARN of the IAM role for IoT Topic Rules."
  value       = aws_iam_role.iot_rule.arn
}

output "iot_rule_iam_role_name" {
  description = "The name of the IAM role for IoT Topic Rules."
  value       = aws_iam_role.iot_rule.name
}

output "iot_logging_iam_role_arn" {
  description = "The ARN of the IAM role for IoT Logging Options."
  value       = aws_iam_role.iot_logging.arn
}

output "iot_logging_iam_role_name" {
  description = "The name of the IAM role for IoT Logging Options."
  value       = aws_iam_role.iot_logging.name
}

output "lambda_log_group_name" {
  description = "The name of the CloudWatch Log Group for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "lambda_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for the Lambda function."
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "iot_errors_log_group_name" {
  description = "The name of the CloudWatch Log Group for IoT Rule errors."
  value       = aws_cloudwatch_log_group.iot_errors.name
}

output "iot_errors_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for IoT Rule errors."
  value       = aws_cloudwatch_log_group.iot_errors.arn
}

output "iot_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for IoT Logging Options."
  value       = aws_cloudwatch_log_group.iot_logs.name
}

output "iot_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for IoT Logging Options."
  value       = aws_cloudwatch_log_group.iot_logs.arn
}

output "iot_device_policy_name" {
  description = "The name of the IoT Device Policy."
  value       = aws_iot_policy.device.name
}

output "iot_device_policy_arn" {
  description = "The ARN of the IoT Device Policy."
  value       = aws_iot_policy.device.arn
}

output "iot_telemetry_to_kinesis_rule_name" {
  description = "The name of the IoT Topic Rule for telemetry to Kinesis."
  value       = aws_iot_topic_rule.telemetry_to_kinesis.name
}

output "iot_telemetry_to_kinesis_rule_arn" {
  description = "The ARN of the IoT Topic Rule for telemetry to Kinesis."
  value       = aws_iot_topic_rule.telemetry_to_kinesis.arn
}

output "iot_telemetry_to_s3_rule_name" {
  description = "The name of the IoT Topic Rule for telemetry to S3."
  value       = aws_iot_topic_rule.telemetry_to_s3.name
}

output "iot_telemetry_to_s3_rule_arn" {
  description = "The ARN of the IoT Topic Rule for telemetry to S3."
  value       = aws_iot_topic_rule.telemetry_to_s3.arn
}

output "timestream_database_name" {
  description = "The name of the Timestream database."
  value       = aws_timestreamwrite_database.main.database_name
}

output "timestream_database_arn" {
  description = "The ARN of the Timestream database."
  value       = aws_timestreamwrite_database.main.arn
}

output "timestream_table_name" {
  description = "The name of the Timestream table."
  value       = aws_timestreamwrite_table.main.table_name
}

output "timestream_table_arn" {
  description = "The ARN of the Timestream table."
  value       = aws_timestreamwrite_table.main.arn
}

output "lambda_dlq_name" {
  description = "The name of the SQS Dead Letter Queue for Lambda."
  value       = aws_sqs_queue.lambda_dlq.name
}

output "lambda_dlq_url" {
  description = "The URL of the SQS Dead Letter Queue for Lambda."
  value       = aws_sqs_queue.lambda_dlq.id
}

output "lambda_dlq_arn" {
  description = "The ARN of the SQS Dead Letter Queue for Lambda."
  value       = aws_sqs_queue.lambda_dlq.arn
}

output "lambda_processor_function_name" {
  description = "The name of the Lambda stream processor function."
  value       = aws_lambda_function.processor.function_name
}

output "lambda_processor_function_arn" {
  description = "The ARN of the Lambda stream processor function."
  value       = aws_lambda_function.processor.arn
}

output "lambda_processor_invoke_arn" {
  description = "The invoke ARN of the Lambda stream processor function."
  value       = aws_lambda_function.processor.invoke_arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.name
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "cloudwatch_alarm_lambda_error_rate_name" {
  description = "The name of the CloudWatch alarm for Lambda error rate."
  value       = aws_cloudwatch_metric_alarm.lambda_error_rate.alarm_name
}

output "cloudwatch_alarm_lambda_error_rate_arn" {
  description = "The ARN of the CloudWatch alarm for Lambda error rate."
  value       = aws_cloudwatch_metric_alarm.lambda_error_rate.arn
}

output "cloudwatch_alarm_kinesis_iterator_age_name" {
  description = "The name of the CloudWatch alarm for Kinesis iterator age."
  value       = aws_cloudwatch_metric_alarm.kinesis_iterator_age.alarm_name
}

output "cloudwatch_alarm_kinesis_iterator_age_arn" {
  description = "The ARN of the CloudWatch alarm for Kinesis iterator age."
  value       = aws_cloudwatch_metric_alarm.kinesis_iterator_age.arn
}

output "cloudwatch_alarm_dynamodb_throttled_events_name" {
  description = "The name of the CloudWatch alarm for DynamoDB throttled events."
  value       = aws_cloudwatch_metric_alarm.dynamodb_throttled_events.alarm_name
}

output "cloudwatch_alarm_dynamodb_throttled_events_arn" {
  description = "The ARN of the CloudWatch alarm for DynamoDB throttled events."
  value       = aws_cloudwatch_metric_alarm.dynamodb_throttled_events.arn
}

output "cloudwatch_alarm_timestream_write_errors_name" {
  description = "The name of the CloudWatch alarm for Timestream write errors."
  value       = aws_cloudwatch_metric_alarm.timestream_write_errors.alarm_name
}

output "cloudwatch_alarm_timestream_write_errors_arn" {
  description = "The ARN of the CloudWatch alarm for Timestream write errors."
  value       = aws_cloudwatch_metric_alarm.timestream_write_errors.arn
}
