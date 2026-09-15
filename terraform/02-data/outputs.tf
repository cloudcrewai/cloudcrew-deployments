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
  description = "The ARN of the Secrets Manager secret storing the master user credentials for the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.master_user_secret[0].secret_arn
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
  description = "The ID (name) of the S3 assets bucket."
  value       = aws_s3_bucket.assets.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 assets bucket."
  value       = aws_s3_bucket.assets.arn
}

output "rds_kms_key_arn" {
  description = "The ARN of the KMS key used for RDS encryption."
  value       = aws_kms_key.rds.arn
}

output "rds_kms_alias_name" {
  description = "The name of the KMS alias for RDS encryption."
  value       = aws_kms_alias.rds.name
}

output "elasticache_kms_key_arn" {
  description = "The ARN of the KMS key used for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "elasticache_kms_alias_name" {
  description = "The name of the KMS alias for ElastiCache encryption."
  value       = aws_kms_alias.elasticache.name
}

output "s3_kms_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "s3_kms_alias_name" {
  description = "The name of the KMS alias for S3 encryption."
  value       = aws_kms_alias.s3.name
}

output "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS Enhanced Monitoring."
  value       = aws_iam_role.rds_monitoring.arn
}

output "rds_cluster_id" {
  description = "The ID of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.id
}

output "rds_cluster_arn" {
  description = "The ARN of the RDS Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.main.arn
}

output "redis_replication_group_id" {
  description = "The ID of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "redis_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.main.arn
}

output "alb_logs_bucket_id" {
  description = "The ID (name) of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}
