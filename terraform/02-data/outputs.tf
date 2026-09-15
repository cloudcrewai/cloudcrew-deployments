output "db_endpoint" {
  description = "The connection endpoint of the RDS instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port on which the RDS instance accepts connections."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing RDS credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "The port on which the ElastiCache Redis replication group accepts connections."
  value       = aws_elasticache_replication_group.main.port
}

output "s3_bucket_id" {
  description = "The ID (name) of the main application assets S3 bucket."
  value       = aws_s3_bucket.assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the main application assets S3 bucket."
  value       = aws_s3_bucket.assets.arn
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS enhanced monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_s3_bucket_id" {
  description = "The ID (name) of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "config_s3_bucket_id" {
  description = "The ID (name) of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
