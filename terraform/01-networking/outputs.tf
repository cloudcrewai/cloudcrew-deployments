output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC."
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = aws_nat_gateway.main[*].id
}

output "app_security_group_id" {
  description = "The ID of the security group for Lambda functions (acting as application SG)."
  value       = aws_security_group.lambda.id
}

output "db_security_group_id" {
  description = "The ID of the security group for database instances."
  value       = aws_security_group.db.id
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for logs."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for logs."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3 buckets."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3 buckets."
  value       = aws_kms_key.s3.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_config_notifications_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "s3_cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "s3_config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "s3_config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "iam_flow_logs_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "iam_cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "iam_config_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "db_subnet_group_id" {
  description = "The ID of the database subnet group."
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the database subnet group."
  value       = aws_db_subnet_group.main.arn
}

output "vpc_egress_security_group_id" {
  description = "The ID of the VPC egress security group."
  value       = aws_security_group.vpc_egress.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the VPC endpoints security group."
  value       = aws_security_group.vpc_endpoints.id
}

output "cloudwatch_flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudwatch_flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudwatch_cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudwatch_cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_main_arn" {
  description = "The ARN of the main CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account."
  value       = aws_securityhub_account.main.id
}
