output "kms_aurora_db_key_id" {
  description = "The ID of the KMS key for Aurora DB encryption."
  value       = aws_kms_key.aurora_db.key_id
}

output "kms_aurora_db_key_arn" {
  description = "The ARN of the KMS key for Aurora DB encryption."
  value       = aws_kms_key.aurora_db.arn
}

output "kms_aurora_db_alias_name" {
  description = "The name of the KMS alias for Aurora DB encryption."
  value       = aws_kms_alias.aurora_db.name
}

output "kms_aurora_db_alias_arn" {
  description = "The ARN of the KMS alias for Aurora DB encryption."
  value       = aws_kms_alias.aurora_db.arn
}

output "kms_rds_mysql_db_key_id" {
  description = "The ID of the KMS key for RDS MySQL DB encryption."
  value       = aws_kms_key.rds_mysql_db.key_id
}

output "kms_rds_mysql_db_key_arn" {
  description = "The ARN of the KMS key for RDS MySQL DB encryption."
  value       = aws_kms_key.rds_mysql_db.arn
}

output "kms_rds_mysql_db_alias_name" {
  description = "The name of the KMS alias for RDS MySQL DB encryption."
  value       = aws_kms_alias.rds_mysql_db.name
}

output "kms_rds_mysql_db_alias_arn" {
  description = "The ARN of the KMS alias for RDS MySQL DB encryption."
  value       = aws_kms_alias.rds_mysql_db.arn
}

output "kms_elasticache_key_id" {
  description = "The ID of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.key_id
}

output "kms_elasticache_key_arn" {
  description = "The ARN of the KMS key for ElastiCache encryption."
  value       = aws_kms_key.elasticache.arn
}

output "kms_elasticache_alias_name" {
  description = "The name of the KMS alias for ElastiCache encryption."
  value       = aws_kms_alias.elasticache.name
}

output "kms_elasticache_alias_arn" {
  description = "The ARN of the KMS alias for ElastiCache encryption."
  value       = aws_kms_alias.elasticache.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "The name of the KMS alias for CloudWatch Logs encryption."
  value       = aws_kms_alias.cloudwatch_logs.name
}

output "kms_cloudwatch_logs_alias_arn" {
  description = "The ARN of the KMS alias for CloudWatch Logs encryption."
  value       = aws_kms_alias.cloudwatch_logs.arn
}

output "secretsmanager_aurora_db_credentials_arn" {
  description = "The ARN of the Secrets Manager secret for Aurora DB credentials."
  value       = aws_secretsmanager_secret.aurora_db_credentials.arn
}

output "secretsmanager_aurora_db_credentials_name" {
  description = "The name of the Secrets Manager secret for Aurora DB credentials."
  value       = aws_secretsmanager_secret.aurora_db_credentials.name
}

output "secretsmanager_rds_mysql_credentials_arn" {
  description = "The ARN of the Secrets Manager secret for RDS MySQL credentials."
  value       = aws_secretsmanager_secret.rds_mysql_credentials.arn
}

output "secretsmanager_rds_mysql_credentials_name" {
  description = "The name of the Secrets Manager secret for RDS MySQL credentials."
  value       = aws_secretsmanager_secret.rds_mysql_credentials.name
}

output "secretsmanager_elasticache_auth_token_arn" {
  description = "The ARN of the Secrets Manager secret for ElastiCache auth token."
  value       = aws_secretsmanager_secret.elasticache_auth_token.arn
}

output "secretsmanager_elasticache_auth_token_name" {
  description = "The name of the Secrets Manager secret for ElastiCache auth token."
  value       = aws_secretsmanager_secret.elasticache_auth_token.name
}

output "cloudwatch_log_group_aurora_arn" {
  description = "The ARN of the CloudWatch Log Group for Aurora."
  value       = aws_cloudwatch_log_group.aurora.arn
}

output "cloudwatch_log_group_aurora_name" {
  description = "The name of the CloudWatch Log Group for Aurora."
  value       = aws_cloudwatch_log_group.aurora.name
}

output "cloudwatch_log_group_rds_mysql_arn" {
  description = "The ARN of the CloudWatch Log Group for RDS MySQL."
  value       = aws_cloudwatch_log_group.rds_mysql.arn
}

output "cloudwatch_log_group_rds_mysql_name" {
  description = "The name of the CloudWatch Log Group for RDS MySQL."
  value       = aws_cloudwatch_log_group.rds_mysql.name
}

output "cloudwatch_log_group_elasticache_arn" {
  description = "The ARN of the CloudWatch Log Group for ElastiCache."
  value       = aws_cloudwatch_log_group.elasticache.arn
}

output "cloudwatch_log_group_elasticache_name" {
  description = "The name of the CloudWatch Log Group for ElastiCache."
  value       = aws_cloudwatch_log_group.elasticache.name
}

output "cloudwatch_log_group_cloudtrail_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudwatch_log_group_cloudtrail_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_iam_role_name" {
  description = "The name of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail trail."
  value       = aws_cloudtrail.main.id
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail trail."
  value       = aws_cloudtrail.main.name
}
