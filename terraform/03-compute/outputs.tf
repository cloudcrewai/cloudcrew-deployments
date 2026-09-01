output "kms_s3_encryption_key_id" {
  description = "KMS Key ID for S3 Data Lake encryption"
  value       = aws_kms_key.s3_encryption.key_id
}

output "kms_s3_encryption_key_arn" {
  description = "KMS Key ARN for S3 Data Lake encryption"
  value       = aws_kms_key.s3_encryption.arn
}

output "kms_s3_encryption_alias_name" {
  description = "KMS Alias Name for S3 Data Lake encryption"
  value       = aws_kms_alias.s3_encryption.name
}

output "kms_s3_encryption_alias_arn" {
  description = "KMS Alias ARN for S3 Data Lake encryption"
  value       = aws_kms_alias.s3_encryption.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "config_iam_role_name" {
  description = "IAM Role Name for AWS Config"
  value       = aws_iam_role.config.name
}

output "config_iam_role_arn" {
  description = "IAM Role ARN for AWS Config"
  value       = aws_iam_role.config.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config Configuration Recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_delivery_channel_name" {
  description = "Name of the AWS Config Delivery Channel"
  value       = aws_config_delivery_channel.main.name
}

output "config_logs_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for AWS Config logs"
  value       = aws_cloudwatch_log_group.config_logs.name
}

output "config_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for AWS Config logs"
  value       = aws_cloudwatch_log_group.config_logs.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.main.arn
}

output "guardduty_findings_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for GuardDuty findings"
  value       = aws_cloudwatch_log_group.guardduty_findings.name
}

output "guardduty_findings_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for GuardDuty findings"
  value       = aws_cloudwatch_log_group.guardduty_findings.arn
}

output "guardduty_findings_event_rule_name" {
  description = "Name of the CloudWatch Event Rule for GuardDuty findings"
  value       = aws_cloudwatch_event_rule.guardduty_findings.name
}

output "guardduty_findings_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule for GuardDuty findings"
  value       = aws_cloudwatch_event_rule.guardduty_findings.arn
}

output "securityhub_account_id" {
  description = "ID of the Security Hub account"
  value       = aws_securityhub_account.main.id
}

output "transcribe_iam_role_name" {
  description = "IAM Role Name for Amazon Transcribe"
  value       = aws_iam_role.transcribe.name
}

output "transcribe_iam_role_arn" {
  description = "IAM Role ARN for Amazon Transcribe"
  value       = aws_iam_role.transcribe.arn
}

output "cloudwatch_alarm_root_login_name" {
  description = "Name of the CloudWatch Alarm for root login"
  value       = aws_cloudwatch_metric_alarm.root_login.alarm_name
}

output "cloudwatch_alarm_root_login_arn" {
  description = "ARN of the CloudWatch Alarm for root login"
  value       = aws_cloudwatch_metric_alarm.root_login.arn
}

output "cloudwatch_alarm_mfa_disabled_console_login_name" {
  description = "Name of the CloudWatch Alarm for MFA disabled console login"
  value       = aws_cloudwatch_metric_alarm.mfa_disabled_console_login.alarm_name
}

output "cloudwatch_alarm_mfa_disabled_console_login_arn" {
  description = "ARN of the CloudWatch Alarm for MFA disabled console login"
  value       = aws_cloudwatch_metric_alarm.mfa_disabled_console_login.arn
}

output "cloudwatch_alarm_unauthorized_api_calls_name" {
  description = "Name of the CloudWatch Alarm for unauthorized API calls"
  value       = aws_cloudwatch_metric_alarm.unauthorized_api_calls.alarm_name
}

output "cloudwatch_alarm_unauthorized_api_calls_arn" {
  description = "ARN of the CloudWatch Alarm for unauthorized API calls"
  value       = aws_cloudwatch_metric_alarm.unauthorized_api_calls.arn
}
