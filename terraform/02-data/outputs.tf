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
  description = "The ARN of the Secrets Manager secret storing database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "The port for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.port
}

output "s3_bucket_id" {
  description = "The ID of the ALB logs S3 bucket."
  value       = aws_s3_bucket.alb_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the ALB logs S3 bucket."
  value       = aws_s3_bucket.alb_logs.arn
}

output "rds_cluster_id" {
  description = "The ID of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora cluster."
  value       = aws_rds_cluster.main.arn
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache."
  value       = aws_security_group.elasticache.id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 bucket encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_backup_key_arn" {
  description = "The ARN of the KMS key used for AWS Backup encryption."
  value       = aws_kms_key.backup.arn
}

output "cloudwatch_flow_logs_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudwatch_cloudtrail_logs_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail_logs.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "config_bucket_id" {
  description = "The ID of the S3 bucket used by AWS Config."
  value       = aws_s3_bucket.config_bucket.id
}

output "config_bucket_arn" {
  description = "The ARN of the S3 bucket used by AWS Config."
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_notifications_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault."
  value       = aws_backup_vault.main.arn
}
