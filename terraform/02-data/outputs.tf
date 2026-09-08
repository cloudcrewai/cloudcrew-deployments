output "db_endpoint" {
  description = "The endpoint for the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.aurora_postgresql.endpoint
}

output "db_port" {
  description = "The port for the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.aurora_postgresql.port
}

output "db_name" {
  description = "The name of the database created in the RDS MySQL instance."
  value       = aws_db_instance.rds_mysql_primary.db_name
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing Aurora DB credentials."
  value       = aws_secretsmanager_secret.aurora_db_credentials.arn
}

output "redis_primary_endpoint" {
  description = "The primary endpoint address for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.elasticache_primary.primary_endpoint_address
}

output "redis_port" {
  description = "The port for the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.elasticache_primary.port
}

output "s3_bucket_id" {
  description = "The ID of the CloudTrail S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "The ARN of the CloudTrail S3 bucket."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "aurora_db_cluster_arn" {
  description = "The ARN of the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.aurora_postgresql.arn
}

output "aurora_db_cluster_reader_endpoint" {
  description = "The reader endpoint for the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.aurora_postgresql.reader_endpoint
}

output "rds_mysql_instance_address" {
  description = "The address of the RDS MySQL primary instance."
  value       = aws_db_instance.rds_mysql_primary.address
}

output "rds_mysql_instance_arn" {
  description = "The ARN of the RDS MySQL primary instance."
  value       = aws_db_instance.rds_mysql_primary.arn
}

output "elasticache_replication_group_arn" {
  description = "The ARN of the ElastiCache Redis replication group."
  value       = aws_elasticache_replication_group.elasticache_primary.arn
}

output "elasticache_security_group_id" {
  description = "The ID of the ElastiCache security group."
  value       = aws_security_group.elasticache.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "cloudwatch_alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}

output "backup_vault_name" {
  description = "The name of the AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "kms_aurora_db_key_arn" {
  description = "The ARN of the KMS key for Aurora DB encryption."
  value       = aws_kms_key.aurora_db.arn
}

output "kms_rds_mysql_db_key_arn" {
  description = "The ARN of the KMS key for RDS MySQL DB encryption."
  value       = aws_kms_key.rds_mysql_db.arn
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_secrets_key_arn" {
  description = "The ARN of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets.arn
}
