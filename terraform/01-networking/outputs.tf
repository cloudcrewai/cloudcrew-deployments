output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "private_route_table_ids" {
  description = "A list of private route table IDs."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "A list of NAT Gateway IDs (empty if NAT Gateway is disabled)."
  value       = aws_nat_gateway.main[*].id
}

output "db_security_group_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.db.id
}

output "database_subnet_ids" {
  description = "A list of database subnet IDs."
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.arn
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "default_security_group_id" {
  description = "The ID of the default security group for the VPC."
  value       = aws_security_group.default.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for logs."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for logs."
  value       = aws_kms_key.logs.id
}

output "kms_logs_alias_name" {
  description = "The alias name of the KMS key for logs."
  value       = aws_kms_alias.logs.name
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3."
  value       = aws_kms_key.s3.id
}

output "kms_s3_alias_name" {
  description = "The alias name of the KMS key for S3."
  value       = aws_kms_alias.s3.name
}

output "kms_main_key_arn" {
  description = "The ARN of the main general-purpose KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_key_id" {
  description = "The ID of the main general-purpose KMS key."
  value       = aws_kms_key.main.id
}

output "kms_main_alias_name" {
  description = "The alias name of the main general-purpose KMS key."
  value       = aws_kms_alias.main.name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "security_alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for security alarms."
  value       = aws_sns_topic.security_alarms.arn
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config."
  value       = aws_s3_bucket.config_bucket.id
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config."
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}
