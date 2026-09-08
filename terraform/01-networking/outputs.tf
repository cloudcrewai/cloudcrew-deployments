output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the main VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs."
  value       = aws_subnet.database[*].id
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
  description = "The ID of the application security group."
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.db.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the VPC Endpoints security group."
  value       = aws_security_group.vpc_endpoints.id
}

output "kms_general_key_id" {
  description = "The ID of the general purpose KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_general_key_arn" {
  description = "The ARN of the general purpose KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs."
  value       = aws_kms_key.logs.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3."
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3."
  value       = aws_kms_key.s3.arn
}

output "kms_rds_key_id" {
  description = "The ID of the KMS key for RDS."
  value       = aws_kms_key.rds.key_id
}

output "kms_rds_key_arn" {
  description = "The ARN of the KMS key for RDS."
  value       = aws_kms_key.rds.arn
}

output "kms_secretsmanager_key_id" {
  description = "The ID of the KMS key for Secrets Manager."
  value       = aws_kms_key.secretsmanager.key_id
}

output "kms_secretsmanager_key_arn" {
  description = "The ARN of the KMS key for Secrets Manager."
  value       = aws_kms_key.secretsmanager.arn
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.arn
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

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector."
  value       = aws_guardduty_detector.main.arn
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.id
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for general CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
