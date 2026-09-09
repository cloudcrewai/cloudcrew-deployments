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
  description = "The ID of the security group for private compute resources (e.g., application servers)"
  value       = aws_security_group.private.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for public-facing resources (e.g., ALB)"
  value       = aws_security_group.public.id
}

output "db_security_group_id" {
  description = "The ID of the security group for database resources"
  value       = aws_security_group.database.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}

output "vpce_security_group_id" {
  description = "The ID of the security group for VPC Endpoints"
  value       = aws_security_group.vpce.id
}

output "sagemaker_api_vpce_id" {
  description = "The ID of the SageMaker API VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_api.id
}

output "sagemaker_api_vpce_dns_names" {
  description = "The DNS names of the SageMaker API VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_api.dns_entry[0].dns_name
}

output "sagemaker_runtime_vpce_id" {
  description = "The ID of the SageMaker Runtime VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_runtime.id
}

output "sagemaker_runtime_vpce_dns_names" {
  description = "The DNS names of the SageMaker Runtime VPC Endpoint"
  value       = aws_vpc_endpoint.sagemaker_runtime.dns_entry[0].dns_name
}

output "s3_vpce_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_api_vpce_id" {
  description = "The ID of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_vpce_dns_names" {
  description = "The DNS names of the ECR API VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.dns_entry[0].dns_name
}

output "ecr_dkr_vpce_id" {
  description = "The ID of the ECR DKR VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_dkr_vpce_dns_names" {
  description = "The DNS names of the ECR DKR VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry[0].dns_name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.arn
}

output "kms_cloudwatch_logs_key_id" {
  description = "The ID of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_key.logs.key_id
}

output "kms_cloudwatch_logs_alias_name" {
  description = "The alias name of the KMS key used for CloudWatch Logs encryption"
  value       = aws_kms_alias.logs.name
}

output "kms_cloudtrail_key_arn" {
  description = "The ARN of the KMS key used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.arn
}

output "kms_cloudtrail_key_id" {
  description = "The ID of the KMS key used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.key_id
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail trail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "securityhub_account_id" {
  description = "The ID of the Security Hub account resource"
  value       = aws_securityhub_account.main.id
}

output "config_s3_bucket_name" {
  description = "The name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_bucket.bucket
}

output "config_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_bucket.arn
}

output "alarms_sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "alarms_sns_topic_name" {
  description = "The name of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.name
}
