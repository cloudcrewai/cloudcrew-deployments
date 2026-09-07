output "kms_alb_logs_key_id" {
  description = "KMS Key ID for ALB access logs encryption"
  value       = aws_kms_key.alb_logs.key_id
}

output "kms_alb_logs_key_arn" {
  description = "KMS Key ARN for ALB access logs encryption"
  value       = aws_kms_key.alb_logs.arn
}

output "kms_alb_logs_alias_name" {
  description = "KMS Alias name for ALB access logs encryption"
  value       = aws_kms_alias.alb_logs.name
}

output "kms_alb_logs_alias_arn" {
  description = "KMS Alias ARN for ALB access logs encryption"
  value       = aws_kms_alias.alb_logs.arn
}

output "kms_ecs_logs_key_id" {
  description = "KMS Key ID for ECS CloudWatch logs encryption"
  value       = aws_kms_key.ecs_logs.key_id
}

output "kms_ecs_logs_key_arn" {
  description = "KMS Key ARN for ECS CloudWatch logs encryption"
  value       = aws_kms_key.ecs_logs.arn
}

output "kms_ecs_logs_alias_name" {
  description = "KMS Alias name for ECS CloudWatch logs encryption"
  value       = aws_kms_alias.ecs_logs.name
}

output "kms_ecs_logs_alias_arn" {
  description = "KMS Alias ARN for ECS CloudWatch logs encryption"
  value       = aws_kms_alias.ecs_logs.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ARN of the IAM role for ECS tasks (application)"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of the IAM role for ECS tasks (application)"
  value       = aws_iam_role.ecs_task.name
}

output "ecs_task_policy_arn" {
  description = "ARN of the IAM policy for ECS tasks (application)"
  value       = aws_iam_policy.ecs_task.arn
}

output "ecs_task_policy_name" {
  description = "Name of the IAM policy for ECS tasks (application)"
  value       = aws_iam_policy.ecs_task.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group for ECS service"
  value       = aws_lb_target_group.ecs_service.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB Target Group for ECS service"
  value       = aws_lb_target_group.ecs_service.name
}

output "alb_https_listener_arn" {
  description = "ARN of the HTTPS listener on the ALB"
  value       = aws_lb_listener.https.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_id" {
  description = "ID of the ECS Cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application image"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application image"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the application image"
  value       = aws_ecr_repository.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_definition_family" {
  description = "Family of the ECS Task Definition"
  value       = aws_ecs_task_definition.app.family
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service"
  value       = aws_ecs_service.app.arn
}

output "ecs_service_id" {
  description = "ID of the ECS Service"
  value       = aws_ecs_service.app.id
}
