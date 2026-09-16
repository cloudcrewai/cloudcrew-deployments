output "kms_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "The name of the main KMS alias."
  value       = aws_kms_alias.main.name
}

output "kms_alias_arn" {
  description = "The ARN of the main KMS alias."
  value       = aws_kms_alias.main.arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.main.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.main.arn
}

output "dynamodb_table_id" {
  description = "The ID of the DynamoDB table (same as name)."
  value       = aws_dynamodb_table.main.id
}
