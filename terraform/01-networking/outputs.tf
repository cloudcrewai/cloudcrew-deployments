output "vpc_id" {
  description = "The ID of the main VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "kms_main_key_arn" {
  description = "ARN of the main KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_main_key_id" {
  description = "ID of the main KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_alias_name" {
  description = "Name of the KMS alias for CloudWatch Logs"
  value       = aws_kms_alias.logs.name
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key for S3 bucket encryption"
  value       = aws_kms_key.s3.arn
}

output "kms_s3_key_id" {
  description = "ID of the KMS key for S3 bucket encryption"
  value       = aws_kms_key.s3.key_id
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_s3_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_s3_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_iam_role_arn" {
  description = "ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "config_iam_role_arn" {
  description = "ARN of the IAM role for AWS Config"
  value       = aws_iam_role.config.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch Alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_config_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config.arn
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "flow_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "ID of the Security Hub account resource"
  value       = aws_securityhub_account.main.id
}

output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.main.name
}
