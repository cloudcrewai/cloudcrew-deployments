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
  description = "The ARN of the Secrets Manager secret storing the database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for logs."
  value       = aws_s3_bucket.s3_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for logs."
  value       = aws_s3_bucket.s3_logs.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 bucket encryption."
  value       = aws_kms_key.s3.arn
}

output "s3_logs_bucket_name" {
  description = "The name of the S3 bucket used for logs."
  value       = aws_s3_bucket.s3_logs.bucket
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_id" {
  description = "The ID of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "rds_proxy_endpoint" {
  description = "The endpoint for the RDS Proxy."
  value       = aws_db_proxy.main.endpoint
}

output "rds_proxy_arn" {
  description = "The ARN for the RDS Proxy."
  value       = aws_db_proxy.main.arn
}

output "cloudwatch_log_group_cloudtrail_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_log_group_rds_name" {
  description = "The name of the CloudWatch Log Group for RDS Aurora cluster logs."
  value       = aws_cloudwatch_log_group.rds.name
}

output "cloudwatch_log_group_db_proxy_name" {
  description = "The name of the CloudWatch Log Group for RDS Proxy logs."
  value       = aws_cloudwatch_log_group.db_proxy.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account resource."
  value       = aws_securityhub_account.main.id
}
