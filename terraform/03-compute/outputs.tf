output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution IAM Role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task IAM Role"
  value       = aws_iam_role.ecs_task.arn
}

output "lambda_rotation_role_arn" {
  description = "ARN of the Lambda Rotation IAM Role"
  value       = aws_iam_role.lambda_rotation.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application image"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application image"
  value       = aws_ecr_repository.app.arn
}

output "lambda_rotation_function_arn" {
  description = "ARN of the Lambda function for secret rotation"
  value       = aws_lambda_function.rotation.arn
}

output "lambda_rotation_function_name" {
  description = "Name of the Lambda function for secret rotation"
  value       = aws_lambda_function.rotation.function_name
}

output "acm_certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group for the application"
  value       = aws_lb_target_group.app.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS service logs"
  value       = aws_cloudwatch_log_group.ecs_service.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service"
  value       = aws_ecs_service.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.app.name
}

output "app_domain_name" {
  description = "Fully Qualified Domain Name (FQDN) for the application"
  value       = aws_route53_record.app_alias.fqdn
}
