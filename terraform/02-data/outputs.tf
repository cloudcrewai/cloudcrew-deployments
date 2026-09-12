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
  description = "The ARN of the Secrets Manager secret storing the DB credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "The port of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.port
}

output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key for general secrets."
  value       = aws_kms_key.main.key_id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key for general secrets."
  value       = aws_kms_key.main.arn
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "flow_logs_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch Alarms."
  value       = aws_sns_topic.alarms.arn
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config Notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "alb_logs_bucket_id" {
  description = "The ID (name) of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "cloudtrail_logs_bucket_id" {
  description = "The ID (name) of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_logs_bucket_id" {
  description = "The ID (name) of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "db_cluster_identifier" {
  description = "The identifier of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.cluster_identifier
}

output "db_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache Subnet Group."
  value       = aws_elasticache_subnet_group.main.name
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
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

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.main.name
}
