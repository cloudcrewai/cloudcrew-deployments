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
  description = "The ID of the security group for private application compute."
  value       = aws_security_group.private_app.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the public-facing ALB."
  value       = aws_security_group.public_alb.id
}

output "kms_general_key_arn" {
  description = "ARN of the general purpose KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key for S3 encryption."
  value       = aws_kms_key.s3.arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.id
}

output "flow_logs_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account resource."
  value       = aws_securityhub_account.main.id
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.bucket
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for general alarms."
  value       = aws_sns_topic.alarms.arn
}
