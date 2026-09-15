output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
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

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = aws_route_table.database[*].id
}

output "elasticache_security_group_id" {
  description = "The ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

output "vpc_endpoints_security_group_id" {
  description = "The ID of the VPC Endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for logs"
  value       = aws_kms_alias.logs.name
}

output "kms_s3_key_arn" {
  description = "The ARN of the KMS key for S3"
  value       = aws_kms_key.s3.arn
}

output "kms_s3_key_id" {
  description = "The ID of the KMS key for S3"
  value       = aws_kms_key.s3.key_id
}

output "kms_s3_alias_name" {
  description = "The name of the KMS alias for S3"
  value       = aws_kms_alias.s3.name
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_main_key_id" {
  description = "The ID of the main KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_main_alias_name" {
  description = "The name of the main KMS alias"
  value       = aws_kms_alias.main.name
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs_role_arn" {
  description = "The ARN of the IAM Role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "cloudtrail_s3_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "config_s3_bucket_id" {
  description = "The ID of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.id
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "config_sns_topic_arn" {
  description = "The ARN of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config.arn
}

output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}

output "s3_vpc_endpoint_id" {
  description = "The ID of the S3 VPC Gateway Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "secretsmanager_vpc_endpoint_id" {
  description = "The ID of the Secrets Manager VPC Interface Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "kms_vpc_endpoint_id" {
  description = "The ID of the KMS VPC Interface Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

output "ecr_api_vpc_endpoint_id" {
  description = "The ID of the ECR API VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "The ID of the ECR DKR VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "cloudwatch_logs_vpc_endpoint_id" {
  description = "The ID of the CloudWatch Logs VPC Interface Endpoint"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "ssm_vpc_endpoint_id" {
  description = "The ID of the SSM VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_vpc_endpoint_id" {
  description = "The ID of the SSM Messages VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_vpc_endpoint_id" {
  description = "The ID of the EC2 VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "ec2_messages_vpc_endpoint_id" {
  description = "The ID of the EC2 Messages VPC Interface Endpoint"
  value       = aws_vpc_endpoint.ec2_messages.id
}
