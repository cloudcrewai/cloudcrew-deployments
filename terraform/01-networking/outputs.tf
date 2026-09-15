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

output "database_subnet_ids" {
  description = "List of database subnet IDs."
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

output "database_route_table_ids" {
  description = "List of database route table IDs."
  value       = aws_route_table.database[*].id
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_s3_key_id" {
  description = "The ID of the S3 KMS key."
  value       = aws_kms_key.s3.id
}

output "kms_s3_key_arn" {
  description = "The ARN of the S3 KMS key."
  value       = aws_kms_key.s3.arn
}

output "kms_s3_alias_name" {
  description = "The name of the S3 KMS key alias."
  value       = aws_kms_alias.s3.name
}

output "kms_rds_key_id" {
  description = "The ID of the RDS KMS key."
  value       = aws_kms_key.rds.id
}

output "kms_rds_key_arn" {
  description = "The ARN of the RDS KMS key."
  value       = aws_kms_key.rds.arn
}

output "kms_rds_alias_name" {
  description = "The name of the RDS KMS key alias."
  value       = aws_kms_alias.rds.name
}

output "kms_logs_key_id" {
  description = "The ID of the logs KMS key."
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the logs KMS key."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the logs KMS key alias."
  value       = aws_kms_alias.logs.name
}

output "elasticache_security_group_id" {
  description = "The ID of the ElastiCache security group."
  value       = aws_security_group.elasticache.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the VPC Endpoints security group."
  value       = aws_security_group.vpc_endpoints.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.arn
}

output "access_logs_bucket_name" {
  description = "The name of the S3 bucket for access logs."
  value       = aws_s3_bucket.access_logs.id
}

output "access_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for access logs."
  value       = aws_s3_bucket.access_logs.arn
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.id
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role for CloudTrail."
  value       = aws_iam_role.cloudtrail.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role for AWS Config."
  value       = aws_iam_role.config.arn
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "waf_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "waf_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log."
  value       = aws_flow_log.main.id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = aws_cloudtrail.main.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "config_notifications_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account resource."
  value       = aws_securityhub_account.main.id
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS Interface VPC Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "ssm_vpc_endpoint_id" {
  description = "The ID of the SSM Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ssm.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "The ID of the ECR API Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "The ID of the ECR DKR Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "cloudwatch_logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs Interface VPC Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}
