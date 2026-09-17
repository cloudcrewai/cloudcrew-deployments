output "db_endpoint" {
  description = "The connection endpoint for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.database_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing the RDS database credentials."
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
  description = "The ID of the S3 bucket for application assets."
  value       = aws_s3_bucket.s3_app_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for application assets."
  value       = aws_s3_bucket.s3_app_assets.arn
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_secrets_key_arn" {
  description = "The ARN of the KMS key used for Secrets Manager encryption."
  value       = aws_kms_key.secrets.arn
}

output "kms_secrets_key_id" {
  description = "The ID of the KMS key used for Secrets Manager encryption."
  value       = aws_kms_key.secrets.key_id
}

output "kms_backup_key_arn" {
  description = "The ARN of the KMS key used for AWS Backup encryption."
  value       = aws_kms_key.backup.arn
}

output "kms_backup_key_id" {
  description = "The ID of the KMS key used for AWS Backup encryption."
  value       = aws_kms_key.backup.key_id
}

output "kms_alb_logs_key_arn" {
  description = "The ARN of the KMS key used for ALB Logs encryption."
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_key_id" {
  description = "The ID of the KMS key used for ALB Logs encryption."
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_dynamodb_key_arn" {
  description = "The ARN of the KMS key used for DynamoDB encryption."
  value       = aws_kms_key.dynamodb.arn
}

output "kms_dynamodb_key_id" {
  description = "The ID of the KMS key used for DynamoDB encryption."
  value       = aws_kms_key.dynamodb.key_id
}

output "cloudwatch_rds_log_group_name" {
  description = "The name of the CloudWatch Log Group for RDS logs."
  value       = aws_cloudwatch_log_group.rds_logs.name
}

output "cloudwatch_cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.name
}

output "iam_rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "iam_cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup."
  value       = aws_iam_role.backup.arn
}

output "iam_db_proxy_role_arn" {
  description = "The ARN of the IAM role for the RDS Proxy."
  value       = aws_iam_role.db_proxy.arn
}

output "s3_cloudtrail_logs_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "s3_flow_logs_bucket_id" {
  description = "The ID of the S3 bucket for VPC Flow logs."
  value       = aws_s3_bucket.s3_flow_logs.id
}

output "s3_flow_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for VPC Flow logs."
  value       = aws_s3_bucket.s3_flow_logs.arn
}

output "s3_alb_logs_bucket_id" {
  description = "The ID of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.s3_alb_logs.id
}

output "s3_alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.s3_alb_logs.arn
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

output "rds_cluster_id" {
  description = "The ID of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.arn
}

output "rds_cluster_reader_endpoint" {
  description = "The reader endpoint for the RDS Aurora PostgreSQL cluster."
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

output "redis_reader_endpoint" {
  description = "The reader endpoint address for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.id
}

output "redis_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.main.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.main.arn
}
