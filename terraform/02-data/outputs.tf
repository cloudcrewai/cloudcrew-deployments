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
  description = "The ID of the application assets S3 bucket."
  value       = aws_s3_bucket.app_assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the application assets S3 bucket."
  value       = aws_s3_bucket.app_assets.arn
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS encryption."
  value       = aws_kms_key.rds.key_id
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "rds_proxy_endpoint" {
  description = "The endpoint for the RDS DB Proxy."
  value       = aws_db_proxy.main.endpoint
}

output "alb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "flow_logs_bucket_name" {
  description = "The name of the S3 bucket for VPC Flow Logs."
  value       = aws_s3_bucket.flow_logs.bucket
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_s3.bucket
}
