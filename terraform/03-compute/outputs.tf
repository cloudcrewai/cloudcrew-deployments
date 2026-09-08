output "kms_logs_key_id" {
  description = "ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "Name of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.logs.name
}

output "kms_logs_alias_arn" {
  description = "ARN of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.logs.arn
}

output "flow_logs_iam_role_name" {
  description = "Name of the IAM Role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.name
}

output "flow_logs_iam_role_arn" {
  description = "ARN of the IAM Role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_iam_role_name" {
  description = "Name of the IAM Role for CloudTrail to deliver to CloudWatch Logs"
  value       = aws_iam_role.cloudtrail.name
}

output "cloudtrail_iam_role_arn" {
  description = "ARN of the IAM Role for CloudTrail to deliver to CloudWatch Logs"
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "root_login_alarm_name" {
  description = "Name of the CloudWatch Alarm for Root Account Usage"
  value       = aws_cloudwatch_metric_alarm.root_login.alarm_name
}

output "mfa_disabled_login_alarm_name" {
  description = "Name of the CloudWatch Alarm for Console Sign-in Without MFA"
  value       = aws_cloudwatch_metric_alarm.mfa_disabled_login.alarm_name
}

output "unauthorized_api_calls_alarm_name" {
  description = "Name of the CloudWatch Alarm for Unauthorized API Calls"
  value       = aws_cloudwatch_metric_alarm.unauthorized_api_calls.alarm_name
}
