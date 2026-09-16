output "kms_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "The name of the main KMS alias."
  value       = aws_kms_alias.main.name
}

output "kms_alias_arn" {
  description = "The ARN of the main KMS alias."
  value       = aws_kms_alias.main.arn
}

output "app_log_group_name" {
  description = "The name of the main application CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.main.name
}

output "app_log_group_arn" {
  description = "The ARN of the main application CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.main.arn
}

output "iot_errors_log_group_name" {
  description = "The name of the IoT errors CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.iot_errors.name
}

output "iot_errors_log_group_arn" {
  description = "The ARN of the IoT errors CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.iot_errors.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudTrail CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudTrail CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "config_log_group_name" {
  description = "The name of the AWS Config CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.config.name
}

output "config_log_group_arn" {
  description = "The ARN of the AWS Config CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.config.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM Role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the Security Group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "vpc_endpoints_security_group_arn" {
  description = "The ARN of the Security Group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoints.arn
}

output "kinesis_vpc_endpoint_id" {
  description = "The ID of the Kinesis VPC Interface Endpoint."
  value       = aws_vpc_endpoint.kinesis.id
}

output "kinesis_vpc_endpoint_dns_names" {
  description = "The DNS names of the Kinesis VPC Interface Endpoint."
  value       = aws_vpc_endpoint.kinesis.dns_entry[0].dns_name
}

output "dynamodb_vpc_endpoint_id" {
  description = "The ID of the DynamoDB VPC Gateway Endpoint."
  value       = aws_vpc_endpoint.dynamodb.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager VPC Interface Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "secretsmanager_vpc_endpoint_dns_names" {
  description = "The DNS names of the Secrets Manager VPC Interface Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.dns_entry[0].dns_name
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS VPC Interface Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpc_endpoint_dns_names" {
  description = "The DNS names of the KMS VPC Interface Endpoint."
  value       = aws_vpc_endpoint.kms.dns_entry[0].dns_name
}

output "cloudwatch_logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs VPC Interface Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_logs_vpc_endpoint_dns_names" {
  description = "The DNS names of the CloudWatch Logs VPC Interface Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.dns_entry[0].dns_name
}

output "timestream_write_vpc_endpoint_id" {
  description = "The ID of the Timestream Write VPC Interface Endpoint."
  value       = aws_vpc_endpoint.timestream_write.id
}

output "timestream_write_vpc_endpoint_dns_names" {
  description = "The DNS names of the Timestream Write VPC Interface Endpoint."
  value       = aws_vpc_endpoint.timestream_write.dns_entry[0].dns_name
}

output "timestream_query_vpc_endpoint_id" {
  description = "The ID of the Timestream Query VPC Interface Endpoint."
  value       = aws_vpc_endpoint.timestream_query.id
}

output "timestream_query_vpc_endpoint_dns_names" {
  description = "The DNS names of the Timestream Query VPC Interface Endpoint."
  value       = aws_vpc_endpoint.timestream_query.dns_entry[0].dns_name
}

output "timestream_database_name" {
  description = "The name of the Timestream database for IoT metrics."
  value       = aws_timestreamwrite_database.iot_metrics.database_name
}

output "timestream_database_arn" {
  description = "The ARN of the Timestream database for IoT metrics."
  value       = aws_timestreamwrite_database.iot_metrics.arn
}

output "timestream_table_name" {
  description = "The name of the Timestream table for device telemetry."
  value       = aws_timestreamwrite_table.device_telemetry.table_name
}

output "timestream_table_arn" {
  description = "The ARN of the Timestream table for device telemetry."
  value       = aws_timestreamwrite_table.device_telemetry.arn
}

output "iot_rule_iam_role_arn" {
  description = "The ARN of the IAM Role for IoT Topic Rules."
  value       = aws_iam_role.iot_rule.arn
}

output "iot_device_policy_name" {
  description = "The name of the IoT Policy for devices."
  value       = aws_iot_policy.device.name
}

output "iot_device_policy_arn" {
  description = "The ARN of the IoT Policy for devices."
  value       = aws_iot_policy.device.arn
}

output "iot_telemetry_to_kinesis_rule_name" {
  description = "The name of the IoT Topic Rule for telemetry to Kinesis."
  value       = aws_iot_topic_rule.telemetry_to_kinesis.name
}

output "iot_telemetry_to_s3_rule_name" {
  description = "The name of the IoT Topic Rule for telemetry to S3."
  value       = aws_iot_topic_rule.telemetry_to_s3.name
}

output "iot_telemetry_to_timestream_rule_name" {
  description = "The name of the IoT Topic Rule for telemetry to Timestream."
  value       = aws_iot_topic_rule.telemetry_to_timestream.name
}

output "iot_logging_iam_role_arn" {
  description = "The ARN of the IAM Role for IoT Logging."
  value       = aws_iam_role.iot_logging.arn
}

output "lambda_processor_function_name" {
  description = "The name of the Lambda processor function."
  value       = aws_lambda_function.processor.function_name
}

output "lambda_processor_function_arn" {
  description = "The ARN of the Lambda processor function."
  value       = aws_lambda_function.processor.arn
}

output "lambda_processor_iam_role_arn" {
  description = "The ARN of the IAM Role for the Lambda processor function."
  value       = aws_iam_role.lambda_processor.arn
}

output "lambda_dlq_queue_url" {
  description = "The URL of the Lambda Dead Letter Queue (DLQ)."
  value       = aws_sqs_queue.lambda_dlq.id
}

output "lambda_dlq_queue_arn" {
  description = "The ARN of the Lambda Dead Letter Queue (DLQ)."
  value       = aws_sqs_queue.lambda_dlq.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.name
}

output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch Dashboard for IoT monitoring."
  value       = aws_cloudwatch_dashboard.iot_monitoring.dashboard_name
}

output "cloudtrail_s3_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM Role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "sns_cloudtrail_notifications_topic_arn" {
  description = "The ARN of the SNS topic for CloudTrail notifications."
  value       = aws_sns_topic.cloudtrail_notifications.arn
}

output "sns_cloudtrail_notifications_topic_name" {
  description = "The name of the SNS topic for CloudTrail notifications."
  value       = aws_sns_topic.cloudtrail_notifications.name
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail trail."
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "config_s3_bucket_id" {
  description = "The ID of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.id
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.arn
}

output "sns_config_notifications_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "sns_config_notifications_topic_name" {
  description = "The name of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.name
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM Role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.main.name
}

output "config_delivery_channel_name" {
  description = "The name of the AWS Config delivery channel."
  value       = aws_config_delivery_channel.main.name
}
