output "alb_logs_kms_key_id" {
  description = "ID of the KMS key for ALB access logs"
  value       = aws_kms_key.alb_logs.key_id
}

output "alb_logs_kms_key_arn" {
  description = "ARN of the KMS key for ALB access logs"
  value       = aws_kms_key.alb_logs.arn
}

output "alb_logs_kms_alias_name" {
  description = "Name of the KMS alias for ALB access logs"
  value       = aws_kms_alias.alb_logs.name
}

output "cloudwatch_logs_kms_key_id" {
  description = "ID of the KMS key for CloudWatch logs"
  value       = aws_kms_key.cloudwatch_logs.key_id
}

output "cloudwatch_logs_kms_key_arn" {
  description = "ARN of the KMS key for CloudWatch logs"
  value       = aws_kms_key.cloudwatch_logs.arn
}

output "cloudwatch_logs_kms_alias_name" {
  description = "Name of the KMS alias for CloudWatch logs"
  value       = aws_kms_alias.cloudwatch_logs.name
}

output "waf_logs_bucket_name" {
  description = "Name of the S3 bucket for WAF logs"
  value       = aws_s3_bucket.waf_logs.bucket
}

output "waf_logs_bucket_arn" {
  description = "ARN of the S3 bucket for WAF logs"
  value       = aws_s3_bucket.waf_logs.arn
}

output "hosted_zone_id" {
  description = "ID of the Route53 Hosted Zone"
  value       = aws_route53_zone.main.zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the Route53 Hosted Zone"
  value       = aws_route53_zone.main.name_servers
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

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group for the application"
  value       = aws_lb_target_group.app.arn
}

output "alb_https_listener_arn" {
  description = "ARN of the HTTPS listener for the ALB"
  value       = aws_lb_listener.https.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the application"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the application"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository for the application"
  value       = aws_ecr_repository.app.arn
}

output "ecs_app_log_group_name" {
  description = "Name of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.name
}

output "ecs_app_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECS application logs"
  value       = aws_cloudwatch_log_group.ecs_app.arn
}

output "general_log_group_name" {
  description = "Name of the general CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.name
}

output "general_log_group_arn" {
  description = "ARN of the general CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition for the application"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service for the application"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service for the application"
  value       = aws_ecs_service.app.arn
}

output "sns_alarms_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}
