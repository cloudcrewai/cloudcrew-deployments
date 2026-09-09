output "kms_sagemaker_key_id" {
  description = "The ID of the KMS key used for SageMaker and CloudWatch Logs."
  value       = aws_kms_key.main.key_id
}

output "kms_sagemaker_key_arn" {
  description = "The ARN of the KMS key used for SageMaker and CloudWatch Logs."
  value       = aws_kms_key.main.arn
}

output "kms_sagemaker_alias_name" {
  description = "The name of the KMS alias for the SageMaker key."
  value       = aws_kms_alias.main.name
}

output "kms_sagemaker_alias_arn" {
  description = "The ARN of the KMS alias for the SageMaker key."
  value       = aws_kms_alias.main.arn
}

output "ecr_sagemaker_images_repository_name" {
  description = "The name of the ECR repository for SageMaker custom images."
  value       = aws_ecr_repository.sagemaker_images.name
}

output "ecr_sagemaker_images_repository_arn" {
  description = "The ARN of the ECR repository for SageMaker custom images."
  value       = aws_ecr_repository.sagemaker_images.arn
}

output "ecr_sagemaker_images_repository_url" {
  description = "The URL of the ECR repository for SageMaker custom images."
  value       = aws_ecr_repository.sagemaker_images.repository_url
}

output "iam_sagemaker_execution_role_name" {
  description = "The name of the IAM role for SageMaker execution."
  value       = aws_iam_role.sagemaker_execution.name
}

output "iam_sagemaker_execution_role_arn" {
  description = "The ARN of the IAM role for SageMaker execution."
  value       = aws_iam_role.sagemaker_execution.arn
}

output "sagemaker_model_security_group_id" {
  description = "The ID of the security group for SageMaker model VPC configuration."
  value       = aws_security_group.sagemaker_model.id
}

output "vpce_security_group_id" {
  description = "The ID of the security group for VPC Interface Endpoints."
  value       = aws_security_group.vpce.id
}

output "sagemaker_api_vpce_id" {
  description = "The ID of the SageMaker API VPC Endpoint."
  value       = aws_vpc_endpoint.sagemaker_api.id
}

output "sagemaker_api_vpce_dns_name" {
  description = "The DNS name of the SageMaker API VPC Endpoint."
  value       = aws_vpc_endpoint.sagemaker_api.dns_entry[0].dns_name
}

output "sagemaker_runtime_vpce_id" {
  description = "The ID of the SageMaker Runtime VPC Endpoint."
  value       = aws_vpc_endpoint.sagemaker_runtime.id
}

output "sagemaker_runtime_vpce_dns_name" {
  description = "The DNS name of the SageMaker Runtime VPC Endpoint."
  value       = aws_vpc_endpoint.sagemaker_runtime.dns_entry[0].dns_name
}

output "ecr_api_vpce_id" {
  description = "The ID of the ECR API VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_api_vpce_dns_name" {
  description = "The DNS name of the ECR API VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_api.dns_entry[0].dns_name
}

output "ecr_dkr_vpce_id" {
  description = "The ID of the ECR DKR VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_dkr_vpce_dns_name" {
  description = "The DNS name of the ECR DKR VPC Endpoint."
  value       = aws_vpc_endpoint.ecr_dkr.dns_entry[0].dns_name
}

output "kms_vpce_id" {
  description = "The ID of the KMS VPC Endpoint."
  value       = aws_vpc_endpoint.kms.id
}

output "kms_vpce_dns_name" {
  description = "The DNS name of the KMS VPC Endpoint."
  value       = aws_vpc_endpoint.kms.dns_entry[0].dns_name
}

output "secretsmanager_vpce_id" {
  description = "The ID of the Secrets Manager VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "secretsmanager_vpce_dns_name" {
  description = "The DNS name of the Secrets Manager VPC Endpoint."
  value       = aws_vpc_endpoint.secretsmanager.dns_entry[0].dns_name
}

output "cloudwatch_logs_vpce_id" {
  description = "The ID of the CloudWatch Logs VPC Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}

output "cloudwatch_logs_vpce_dns_name" {
  description = "The DNS name of the CloudWatch Logs VPC Endpoint."
  value       = aws_vpc_endpoint.cloudwatch_logs.dns_entry[0].dns_name
}

output "sagemaker_model_package_group_name" {
  description = "The name of the SageMaker Model Package Group."
  value       = aws_sagemaker_model_package_group.main.model_package_group_name
}

output "sagemaker_model_package_group_arn" {
  description = "The ARN of the SageMaker Model Package Group."
  value       = aws_sagemaker_model_package_group.main.arn
}

output "sagemaker_model_name" {
  description = "The name of the SageMaker Model."
  value       = aws_sagemaker_model.main.name
}

output "sagemaker_model_arn" {
  description = "The ARN of the SageMaker Model."
  value       = aws_sagemaker_model.main.arn
}

output "sagemaker_endpoint_configuration_name" {
  description = "The name of the SageMaker Endpoint Configuration."
  value       = aws_sagemaker_endpoint_configuration.main.name
}

output "sagemaker_endpoint_name" {
  description = "The name of the SageMaker Endpoint."
  value       = aws_sagemaker_endpoint.main.name
}

output "sagemaker_endpoint_arn" {
  description = "The ARN of the SageMaker Endpoint."
  value       = aws_sagemaker_endpoint.main.arn
}

output "cloudwatch_log_group_sagemaker_name" {
  description = "The name of the CloudWatch Log Group for SageMaker."
  value       = aws_cloudwatch_log_group.sagemaker.name
}

output "cloudwatch_log_group_sagemaker_arn" {
  description = "The ARN of the CloudWatch Log Group for SageMaker."
  value       = aws_cloudwatch_log_group.sagemaker.arn
}
