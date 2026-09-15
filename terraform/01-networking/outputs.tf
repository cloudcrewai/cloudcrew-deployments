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
  description = "The ID of the security group for application tasks."
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS database."
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

output "kms_flow_logs_key_id" {
  description = "The ID of the KMS key for flow logs."
  value       = aws_kms_key.flow_logs.key_id
}

output "kms_flow_logs_key_arn" {
  description = "The ARN of the KMS key for flow logs."
  value       = aws_kms_key.flow_logs.arn
}

output "kms_cloudtrail_key_id" {
  description = "The ID of the KMS key for CloudTrail."
  value       = aws_kms_key.cloudtrail.key_id
}

output "kms_cloudtrail_key_arn" {
  description = "The ARN of the KMS key for CloudTrail."
  value       = aws_kms_key.cloudtrail.arn
}

output "kms_config_key_id" {
  description = "The ID of the KMS key for AWS Config."
  value       = aws_kms_key.config.key_id
}

output "kms_config_key_arn" {
  description = "The ARN of the KMS key for AWS Config."
  value       = aws_kms_key.config.arn
}

output "kms_sns_key_id" {
  description = "The ID of the KMS key for SNS topics."
  value       = aws_kms_key.sns.key_id
}

output "kms_sns_key_arn" {
  description = "The ARN of the KMS key for SNS topics."
  value       = aws_kms_key.sns.arn
}

output "cloudtrail_logs_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "config_logs_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs."
  value       = aws_s3_bucket.config_logs.arn
}

output "alb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.bucket
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
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

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "db_subnet_ids" {
  description = "List of database subnet IDs."
  value       = aws_subnet.db[*].id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB subnet group."
  value       = aws_db_subnet_group.main.name
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache subnet group."
  value       = aws_elasticache_subnet_group.main.name
}

output "elasticache_security_group_id" {
  description = "The ID of the security group for ElastiCache."
  value       = aws_security_group.elasticache.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "flow_logs_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudTrail notifications."
  value       = aws_sns_topic.cloudtrail_notifications.arn
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
  description = "The ID of the Security Hub account."
  value       = aws_securityhub_account.main.id
}

output "config_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for AWS Config."
  value       = aws_cloudwatch_log_group.config.arn
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications."
  value       = aws_sns_topic.config_notifications.arn
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the S3 Gateway VPC Endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_kms_id" {
  description = "The ID of the KMS Interface VPC Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_ecr_api_id" {
  description = "The ID of the ECR API Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_api.id
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "The ID of the ECR DKR Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "vpc_endpoint_cloudwatch_logs_id" {
  description = "The ID of the CloudWatch Logs Interface VPC Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "vpc_endpoint_ssm_id" {
  description = "The ID of the SSM Interface VPC Endpoint."
  value       = aws_vpc_endpoint.ssm.id
}
