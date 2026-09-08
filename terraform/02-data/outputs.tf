output "db_endpoint" {
  description = "The connection endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS Aurora cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}

output "s3_bucket_id" {
  description = "The ID of the CloudTrail logs S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the CloudTrail logs S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key for general encryption."
  value       = aws_kms_key.main.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "config_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for AWS Config."
  value       = aws_cloudwatch_log_group.config.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account resource."
  value       = aws_securityhub_account.main.id
}

output "secrets_manager_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for Secrets Manager."
  value       = aws_vpc_endpoint.secrets_manager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint for KMS."
  value       = aws_vpc_endpoint.kms.id
}

output "db_credentials_secret_arn" {
  description = "The ARN of the Secrets Manager secret for general DB credentials (not master user)."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
