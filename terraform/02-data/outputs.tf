output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "s3_bucket_id" {
  description = "ID of the main S3 data lake bucket."
  value       = aws_s3_bucket.data_lake.id
}

output "s3_bucket_arn" {
  description = "ARN of the main S3 data lake bucket."
  value       = aws_s3_bucket.data_lake.arn
}

output "kms_main_key_id" {
  description = "ID of the main KMS key."
  value       = aws_kms_key.main.id
}

output "kms_main_key_arn" {
  description = "ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "Name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_logs_key_id" {
  description = "ID of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_id" {
  description = "ID of the KMS key for S3 data buckets."
  value       = aws_kms_key.s3.id
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key for S3 data buckets."
  value       = aws_kms_key.s3.arn
}

output "kms_cloudtrail_key_id" {
  description = "ID of the KMS key for CloudTrail logs."
  value       = aws_kms_key.cloudtrail.id
}

output "kms_cloudtrail_key_arn" {
  description = "ARN of the KMS key for CloudTrail logs."
  value       = aws_kms_key.cloudtrail.arn
}

output "kms_backup_key_id" {
  description = "ID of the KMS key for AWS Backup."
  value       = aws_kms_key.backup.id
}

output "kms_backup_key_arn" {
  description = "ARN of the KMS key for AWS Backup."
  value       = aws_kms_key.backup.arn
}

output "iam_flow_logs_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "iam_cloudtrail_role_arn" {
  description = "ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_config_role_arn" {
  description = "ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "iam_backup_role_arn" {
  description = "ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "s3_access_logs_bucket_id" {
  description = "ID of the S3 bucket for S3 access logs."
  value       = aws_s3_bucket.s3_access_logs.id
}

output "s3_access_logs_bucket_arn" {
  description = "ARN of the S3 bucket for S3 access logs."
  value       = aws_s3_bucket.s3_access_logs.arn
}

output "s3_cloudtrail_logs_bucket_id" {
  description = "ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "s3_config_bucket_id" {
  description = "ID of the S3 bucket for AWS Config."
  value       = aws_s3_bucket.config_bucket.id
}

output "s3_config_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config."
  value       = aws_s3_bucket.config_bucket.arn
}

output "vpc_endpoint_s3_gateway_id" {
  description = "ID of the S3 Gateway VPC Endpoint."
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "vpc_endpoint_logs_id" {
  description = "ID of the CloudWatch Logs Interface VPC Endpoint."
  value       = aws_vpc_endpoint.logs.id
}

output "vpc_endpoint_logs_dns_names" {
  description = "DNS names of the CloudWatch Logs Interface VPC Endpoint."
  value       = aws_vpc_endpoint.logs.dns_entry[*].dns_name
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID of the Secrets Manager Interface VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_secretsmanager_dns_names" {
  description = "DNS names of the Secrets Manager Interface VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.dns_entry[*].dns_name
}

output "vpc_endpoint_kms_id" {
  description = "ID of the KMS Interface VPC Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_kms_dns_names" {
  description = "DNS names of the KMS Interface VPC Endpoint."
  value       = aws_vpc_endpoint.kms.dns_entry[*].dns_name
}

output "vpc_endpoint_ssm_id" {
  description = "ID of the SSM Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ssm.id
}

output "vpc_endpoint_ssm_dns_names" {
  description = "DNS names of the SSM Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ssm.dns_entry[*].dns_name
}

output "cloudwatch_flow_logs_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudwatch_flow_logs_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudwatch_cloudtrail_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_cloudtrail_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudwatch_guardduty_log_group_name" {
  description = "Name of the CloudWatch Log Group for GuardDuty."
  value       = aws_cloudwatch_log_group.guardduty.name
}

output "cloudwatch_guardduty_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for GuardDuty."
  value       = aws_cloudwatch_log_group.guardduty.arn
}

output "cloudtrail_id" {
  description = "ID of the main CloudTrail trail."
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_arn" {
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

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "Name of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.name
}

output "backup_vault_name" {
  description = "Name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "backup_plan_arn" {
  description = "ARN of the AWS Backup plan."
  value       = aws_backup_plan.main.arn
}

output "app_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret for application credentials."
  value       = aws_secretsmanager_secret.app_credentials.arn
}

output "app_credentials_secret_name" {
  description = "Name of the Secrets Manager secret for application credentials."
  value       = aws_secretsmanager_secret.app_credentials.name
}
