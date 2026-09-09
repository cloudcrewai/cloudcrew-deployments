output "db_endpoint" {
  description = "The connection endpoint for the RDS database instance."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port for the RDS database instance."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The name of the database created in the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing RDS database credentials."
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
  description = "The ID (name) of the S3 bucket for application assets."
  value       = aws_s3_bucket.s3_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for application assets."
  value       = aws_s3_bucket.s3_assets.arn
}

output "rds_kms_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "elasticache_kms_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "s3_assets_kms_key_arn" {
  description = "The ARN of the KMS key used for S3 application assets encryption."
  value       = aws_kms_key.s3_assets.arn
}

output "s3_alb_logs_kms_key_arn" {
  description = "The ARN of the KMS key used for S3 ALB logs encryption."
  value       = aws_kms_key.s3_alb_logs_encryption.arn
}

output "cloudwatch_logs_kms_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "rds_instance_arn" {
  description = "The ARN of the RDS database instance."
  value       = aws_db_instance.main.arn
}

output "rds_instance_identifier" {
  description = "The identifier of the RDS database instance."
  value       = aws_db_instance.main.identifier
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache Redis."
  value       = aws_security_group.elasticache.id
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "alb_logs_bucket_id" {
  description = "The ID (name) of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.s3_alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.s3_alb_logs.arn
}

output "rds_enhanced_monitoring_log_group_name" {
  description = "The name of the CloudWatch Log Group for RDS Enhanced Monitoring."
  value       = aws_cloudwatch_log_group.rds_enhanced_monitoring.name
}

output "rds_enhanced_monitoring_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for RDS Enhanced Monitoring."
  value       = aws_cloudwatch_log_group.rds_enhanced_monitoring.arn
}
