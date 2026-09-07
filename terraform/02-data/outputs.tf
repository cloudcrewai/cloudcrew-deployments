output "db_endpoint" {
  description = "The connection endpoint for the RDS cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port on which the RDS cluster accepts connections."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS cluster."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
}

output "s3_bucket_id" {
  description = "The ID (name) of the CloudTrail logs S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the CloudTrail logs S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "kms_general_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_general_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_general_alias_name" {
  description = "The name of the alias for the main KMS key."
  value       = aws_kms_alias.main.name
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_name" {
  description = "The name of the alias for the RDS KMS key."
  value       = aws_kms_alias.rds.name
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_name" {
  description = "The name of the alias for the S3 KMS key."
  value       = aws_kms_alias.s3.name
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the alias for the CloudWatch Logs KMS key."
  value       = aws_kms_alias.logs.name
}

output "kms_backup_key_id" {
  description = "The ID of the KMS key used for AWS Backup encryption."
  value       = aws_kms_key.backup.key_id
}

output "kms_backup_key_arn" {
  description = "The ARN of the KMS key used for AWS Backup encryption."
  value       = aws_kms_key.backup.arn
}

output "kms_backup_alias_name" {
  description = "The name of the alias for the AWS Backup KMS key."
  value       = aws_kms_alias.backup.name
}

output "rds_cluster_identifier" {
  description = "The identifier of the RDS cluster."
  value       = aws_rds_cluster.main.cluster_identifier
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS cluster."
  value       = aws_rds_cluster.main.arn
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "s3_alb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "s3_alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "s3_config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "s3_config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "cloudwatch_cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for security alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for security alarms."
  value       = aws_sns_topic.alarms.name
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "config_recorder_name" {
  description = "The name of the AWS Config Configuration Recorder."
  value       = aws_config_configuration_recorder.main.name
}

output "config_delivery_channel_name" {
  description = "The name of the AWS Config Delivery Channel."
  value       = aws_config_delivery_channel.main.name
}
