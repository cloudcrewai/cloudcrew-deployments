output "kms_app_key_id" {
  description = "ID of the KMS key for application secrets"
  value       = aws_kms_key.app.key_id
}

output "kms_app_key_arn" {
  description = "ARN of the KMS key for application secrets"
  value       = aws_kms_key.app.arn
}

output "kms_app_alias_name" {
  description = "Name of the KMS alias for application secrets"
  value       = aws_kms_alias.app.name
}

output "kms_logs_key_id" {
  description = "ID of the KMS key for CloudWatch logs"
  value       = aws_kms_key.logs.key_id
}

output "kms_logs_key_arn" {
  description = "ARN of the KMS key for CloudWatch logs"
  value       = aws_kms_key.logs.arn
}

output "kms_logs_alias_name" {
  description = "Name of the KMS alias for CloudWatch logs"
  value       = aws_kms_alias.logs.name
}

output "kms_s3_alb_logs_key_id" {
  description = "ID of the KMS key for S3 ALB access logs"
  value       = aws_kms_key.s3_alb_logs.key_id
}

output "kms_s3_alb_logs_key_arn" {
  description = "ARN of the KMS key for S3 ALB access logs"
  value       = aws_kms_key.s3_alb_logs.arn
}

output "kms_s3_alb_logs_alias_name" {
  description = "Name of the KMS alias for S3 ALB access logs"
  value       = aws_kms_alias.s3_alb_logs.name
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "api_gateway_id" {
  description = "ID of the API Gateway HTTP API"
  value       = aws_apigatewayv2_api.main.id
}

output "api_gateway_endpoint" {
  description = "Endpoint URL of the API Gateway HTTP API"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_gateway_stage_invoke_url" {
  description = "Invoke URL of the API Gateway HTTP API stage"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Route 53 Hosted Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.main.arn
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.main.arn
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service"
  value       = aws_ecs_service.main.arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.main.name
}

output "cloud_map_namespace_id" {
  description = "ID of the Cloud Map Private DNS Namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "cloud_map_namespace_arn" {
  description = "ARN of the Cloud Map Private DNS Namespace"
  value       = aws_service_discovery_private_dns_namespace.main.arn
}

output "cloud_map_service_id" {
  description = "ID of the Cloud Map Service"
  value       = aws_service_discovery_service.main.id
}

output "cloud_map_service_arn" {
  description = "ARN of the Cloud Map Service"
  value       = aws_service_discovery_service.main.arn
}

output "secrets_manager_app_secret_arn" {
  description = "ARN of the application secret in Secrets Manager"
  value       = aws_secretsmanager_secret.app_secret.arn
}

output "secrets_manager_app_secret_id" {
  description = "ID of the application secret in Secrets Manager"
  value       = aws_secretsmanager_secret.app_secret.id
}

output "lambda_rotation_function_arn" {
  description = "ARN of the Lambda function for secret rotation"
  value       = aws_lambda_function.rotation.arn
}

output "lambda_rotation_function_name" {
  description = "Name of the Lambda function for secret rotation"
  value       = aws_lambda_function.rotation.function_name
}

output "vpc_endpoint_ecr_api_id" {
  description = "ID of the VPC endpoint for ECR API"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ID of the VPC endpoint for ECR DKR"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID of the VPC endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "vpc_endpoint_kms_id" {
  description = "ID of the VPC endpoint for KMS"
  value       = aws_vpc_endpoint.kms.id
}

output "vpc_endpoint_logs_id" {
  description = "ID of the VPC endpoint for CloudWatch Logs"
  value       = aws_vpc_endpoint.logs.id
}

output "cloudwatch_waf_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "cloudwatch_waf_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "cloudwatch_api_gateway_log_group_name" {
  description = "Name of the CloudWatch Log Group for API Gateway logs"
  value       = aws_cloudwatch_log_group.api_gateway_logs.name
}

output "cloudwatch_api_gateway_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for API Gateway logs"
  value       = aws_cloudwatch_log_group.api_gateway_logs.arn
}

output "cloudwatch_ecs_service_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service_logs.name
}

output "cloudwatch_ecs_service_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service_logs.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
