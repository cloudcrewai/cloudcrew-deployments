output "kms_s3_alb_logs_key_id" {
  description = "KMS Key ID for S3 ALB Logs"
  value       = aws_kms_key.s3_alb_logs.key_id
}

output "kms_s3_alb_logs_key_arn" {
  description = "KMS Key ARN for S3 ALB Logs"
  value       = aws_kms_key.s3_alb_logs.arn
}

output "kms_s3_alb_logs_alias_name" {
  description = "KMS Alias Name for S3 ALB Logs"
  value       = aws_kms_alias.s3_alb_logs.name
}

output "kms_cloudwatch_logs_key_id" {
  description = "KMS Key ID for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "kms_cloudwatch_logs_key_arn" {
  description = "KMS Key ARN for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "kms_cloudwatch_logs_alias_name" {
  description = "KMS Alias Name for CloudWatch Logs"
  value       = aws_kms_alias.cloudwatch_logs.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution IAM Role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task IAM Role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_policy_arn" {
  description = "ARN of the ECS Task IAM Policy"
  value       = aws_iam_policy.ecs_task_policy.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
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

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS Cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS Service"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS Service"
  value       = aws_ecs_service.app.arn
}
