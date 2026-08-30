output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "The ARN of the ECS application target group."
  value       = aws_lb_target_group.ecs_app.arn
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

output "alb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.id
}

output "alb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB access logs."
  value       = aws_s3_bucket.alb_logs.arn
}

output "kms_alb_logs_key_arn" {
  description = "The ARN of the KMS key used for ALB access logs encryption."
  value       = aws_kms_key.s3_alb_logs.arn
}

output "kms_cloudwatch_logs_key_arn" {
  description = "The ARN of the KMS key used for CloudWatch logs encryption."
  value       = aws_kms_key.logs.arn
}

output "ecs_app_log_group_name" {
  description = "The name of the CloudWatch Log Group for the ECS application."
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms."
  value       = aws_sns_topic.alarms.arn
}
