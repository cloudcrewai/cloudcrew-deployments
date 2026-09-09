output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways."
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
  description = "List of IDs of the database subnets."
  value       = aws_subnet.database[*].id
}

output "db_subnet_group_id" {
  description = "The ID of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.main.arn
}

output "kms_logs_key_id" {
  description = "The ID of the KMS key used for log encryption."
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "The ARN of the KMS key used for log encryption."
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "The name of the KMS alias for log encryption."
  value       = aws_kms_alias.logs.name
}

output "flow_logs_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "flow_logs_role_arn" {
  description = "The ARN of the IAM role used for VPC Flow Logs."
  value       = aws_iam_role.flow_logs.arn
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

output "vpc_endpoint_sg_id" {
  description = "The ID of the security group for VPC Endpoints."
  value       = aws_security_group.vpc_endpoint.id
}
