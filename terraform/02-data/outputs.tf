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
  description = "ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key used for S3 bucket encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_secrets_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager encryption."
  value       = aws_kms_key.secrets.arn
}

output "kms_sns_key_arn" {
  description = "ARN of the KMS key used for SNS topic encryption."
  value       = aws_kms_key.sns.arn
}

output "iam_rds_monitoring_role_arn" {
  description = "ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
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

output "cloudtrail_logs_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "config_logs_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "cloudwatch_log_group_aurora_arn" {
  description = "ARN of the CloudWatch Log Group for Aurora logs."
  value       = aws_cloudwatch_log_group.aurora.arn
}

output "cloudwatch_log_group_cloudtrail_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudwatch_log_group_config_arn" {
  description = "ARN of the CloudWatch Log Group for AWS Config logs."
  value       = aws_cloudwatch_log_group.config.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_config_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config.arn
}

output "secretsmanager_db_credentials_arn" {
  description = "ARN of the Secrets Manager secret for database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_security_group_id" {
  description = "ID of the security group for the RDS Aurora cluster."
  value       = aws_security_group.db.id
}

output "rds_cluster_arn" {
  description = "ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_id" {
  description = "ID of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS Aurora cluster."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
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
