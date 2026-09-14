output "kms_ebs_key_id" {
  description = "The ID of the KMS key for EBS encryption."
  value       = aws_kms_key.ebs.key_id
}

output "kms_ebs_key_arn" {
  description = "The ARN of the KMS key for EBS encryption."
  value       = aws_kms_key.ebs.arn
}

output "kms_ebs_alias_name" {
  description = "The name of the KMS alias for EBS encryption."
  value       = aws_kms_alias.ebs.name
}

output "kms_ebs_alias_arn" {
  description = "The ARN of the KMS alias for EBS encryption."
  value       = aws_kms_alias.ebs.arn
}

output "kms_secrets_manager_key_id" {
  description = "The ID of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets_manager.key_id
}

output "kms_secrets_manager_key_arn" {
  description = "The ARN of the KMS key for Secrets Manager encryption."
  value       = aws_kms_key.secrets_manager.arn
}

output "kms_secrets_manager_alias_name" {
  description = "The name of the KMS alias for Secrets Manager encryption."
  value       = aws_kms_alias.secrets_manager.name
}

output "kms_secrets_manager_alias_arn" {
  description = "The ARN of the KMS alias for Secrets Manager encryption."
  value       = aws_kms_alias.secrets_manager.arn
}

output "ecr_repository_name" {
  description = "The name of the ECR repository."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository."
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "The Zone ID of the Application Load Balancer."
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "The ARN of the ALB target group for the application."
  value       = aws_lb_target_group.app.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster."
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service."
  value       = aws_ecs_service.app.arn
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for ECS application logs."
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "app_secret_1_arn" {
  description = "The ARN of the first application secret in Secrets Manager."
  value       = aws_secretsmanager_secret.app_secret_1.arn
}

output "app_secret_1_name" {
  description = "The name of the first application secret in Secrets Manager."
  value       = aws_secretsmanager_secret.app_secret_1.name
}

output "app_secret_2_arn" {
  description = "The ARN of the second application secret in Secrets Manager."
  value       = aws_secretsmanager_secret.app_secret_2.arn
}

output "app_secret_2_name" {
  description = "The name of the second application secret in Secrets Manager."
  value       = aws_secretsmanager_secret.app_secret_2.name
}

output "secret_rotation_lambda_function_name" {
  description = "The name of the Lambda function for secret rotation."
  value       = aws_lambda_function.secret_rotation.function_name
}

output "secret_rotation_lambda_function_arn" {
  description = "The ARN of the Lambda function for secret rotation."
  value       = aws_lambda_function.secret_rotation.arn
}

output "alb_route53_record_fqdn" {
  description = "The FQDN of the Route53 A record pointing to the ALB."
  value       = aws_route53_record.alb_dns.fqdn
}
