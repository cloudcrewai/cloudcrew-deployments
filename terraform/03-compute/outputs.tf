output "kms_aurora_secrets_key_id" {
  description = "ID of the KMS key for Aurora/Secrets Manager"
  value       = aws_kms_key.aurora_secrets.key_id
}

output "kms_aurora_secrets_key_arn" {
  description = "ARN of the KMS key for Aurora/Secrets Manager"
  value       = aws_kms_key.aurora_secrets.arn
}

output "kms_aurora_secrets_alias_name" {
  description = "Name of the KMS alias for Aurora/Secrets Manager"
  value       = aws_kms_alias.aurora_secrets.name
}

output "kms_aurora_secrets_alias_arn" {
  description = "ARN of the KMS alias for Aurora/Secrets Manager"
  value       = aws_kms_alias.aurora_secrets.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "Name of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.cloudwatch_logs.name
}

output "kms_cloudwatch_logs_alias_arn" {
  description = "ARN of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.cloudwatch_logs.arn
}

output "secretsmanager_db_credentials_arn" {
  description = "ARN of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secretsmanager_db_credentials_name" {
  description = "Name of the Secrets Manager secret for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "iam_rds_proxy_role_arn" {
  description = "ARN of the IAM role for RDS Proxy"
  value       = aws_iam_role.rds_proxy.arn
}

output "iam_rds_proxy_role_name" {
  description = "Name of the IAM role for RDS Proxy"
  value       = aws_iam_role.rds_proxy.name
}

output "cloudwatch_log_group_aurora_arn" {
  description = "ARN of the CloudWatch Log Group for Aurora"
  value       = aws_cloudwatch_log_group.aurora.arn
}

output "cloudwatch_log_group_aurora_name" {
  description = "Name of the CloudWatch Log Group for Aurora"
  value       = aws_cloudwatch_log_group.aurora.name
}

output "cloudwatch_log_group_vpc_flow_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow.arn
}

output "cloudwatch_log_group_vpc_flow_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow.name
}

output "cloudwatch_log_group_cloudtrail_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail Logs"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudwatch_log_group_cloudtrail_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail Logs"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "iam_cloudtrail_cloudwatch_logs_role_arn" {
  description = "ARN of the IAM role for CloudTrail to deliver logs to CloudWatch"
  value       = aws_iam_role.cloudtrail_cloudwatch_logs.arn
}

output "iam_cloudtrail_cloudwatch_logs_role_name" {
  description = "Name of the IAM role for CloudTrail to deliver logs to CloudWatch"
  value       = aws_iam_role.cloudtrail_cloudwatch_logs.name
}

output "cloudtrail_main_arn" {
  description = "ARN of the main CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_main_name" {
  description = "Name of the main CloudTrail trail"
  value       = aws_cloudtrail.main.name
}
