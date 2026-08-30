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
  description = "The ID of the security group for application tasks"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "The ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "db_security_group_id" {
  description = "The ID of the security group for RDS database instances"
  value       = aws_security_group.db.id
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.logs.arn
}

output "kms_cloudtrail_s3_key_id" {
  description = "The ID of the KMS key for CloudTrail S3 bucket encryption"
  value       = aws_kms_key.cloudtrail_s3.id
}

output "kms_cloudtrail_s3_key_arn" {
  description = "The ARN of the KMS key for CloudTrail S3 bucket encryption"
  value       = aws_kms_key.cloudtrail_s3.arn
}

output "flow_logs_iam_role_arn" {
  description = "The ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "cloudtrail_iam_role_arn" {
  description = "The ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail.arn
}

output "cloudtrail_logs_bucket_id" {
  description = "The ID of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = aws_route_table.database[*].id
}

output "vpc_endpoint_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints"
  value       = aws_security_group.vpc_endpoint.id
}

output "s3_gateway_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "secretsmanager_endpoint_id" {
  description = "The ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager_interface.id
}

output "kms_endpoint_id" {
  description = "The ID of the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms_interface.id
}

output "ssm_endpoint_id" {
  description = "The ID of the SSM Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm_interface.id
}

output "ecr_api_endpoint_id" {
  description = "The ID of the ECR API Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api_interface.id
}

output "ecr_dkr_endpoint_id" {
  description = "The ID of the ECR DKR Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr_interface.id
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}
