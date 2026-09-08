output "kms_aurora_key_id" {
  description = "The ID of the KMS key for Aurora encryption."
  value       = aws_kms_key.aurora.key_id
}

output "kms_aurora_key_arn" {
  description = "The ARN of the KMS key for Aurora encryption."
  value       = aws_kms_key.aurora.arn
}

output "kms_aurora_alias_name" {
  description = "The name of the KMS alias for Aurora encryption."
  value       = aws_kms_alias.aurora.name
}

output "kms_aurora_alias_arn" {
  description = "The ARN of the KMS alias for Aurora encryption."
  value       = aws_kms_alias.aurora.arn
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

output "aurora_log_group_name" {
  description = "The name of the CloudWatch Log Group for Aurora."
  value       = aws_cloudwatch_log_group.aurora.name
}

output "aurora_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for Aurora."
  value       = aws_cloudwatch_log_group.aurora.arn
}
