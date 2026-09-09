output "kms_main_key_id" {
  description = "The ID of the main KMS key."
  value       = aws_kms_key.main.key_id
}

output "kms_main_key_arn" {
  description = "The ARN of the main KMS key."
  value       = aws_kms_key.main.arn
}

output "kms_main_alias_name" {
  description = "The name of the main KMS key alias."
  value       = aws_kms_alias.main.name
}

output "kms_main_alias_arn" {
  description = "The ARN of the main KMS key alias."
  value       = aws_kms_alias.main.arn
}

output "kms_ebs_key_id" {
  description = "The ID of the EBS encryption KMS key."
  value       = aws_kms_key.ebs.key_id
}

output "kms_ebs_key_arn" {
  description = "The ARN of the EBS encryption KMS key."
  value       = aws_kms_key.ebs.arn
}

output "ec2_instance_iam_role_name" {
  description = "The name of the IAM role for EC2 instances."
  value       = aws_iam_role.ec2_instance.name
}

output "ec2_instance_iam_role_arn" {
  description = "The ARN of the IAM role for EC2 instances."
  value       = aws_iam_role.ec2_instance.arn
}

output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2_instance.name
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile."
  value       = aws_iam_instance_profile.ec2_instance.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "The ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}

output "alb_target_group_name" {
  description = "The name of the application target group."
  value       = aws_lb_target_group.app.name
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_name" {
  description = "The domain name of the ACM certificate."
  value       = aws_acm_certificate.main.domain_name
}

output "alb_https_listener_arn" {
  description = "The ARN of the HTTPS listener for the ALB."
  value       = aws_lb_listener.https.arn
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_id" {
  description = "The ID of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.main.id
}

output "waf_logs_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "waf_logs_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for WAF logs."
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "launch_template_id" {
  description = "The ID of the EC2 Launch Template."
  value       = aws_launch_template.app.id
}

output "launch_template_arn" {
  description = "The ARN of the EC2 Launch Template."
  value       = aws_launch_template.app.arn
}

output "launch_template_name" {
  description = "The name of the EC2 Launch Template."
  value       = aws_launch_template.app.name
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.arn
}

output "app_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for the application."
  value       = aws_cloudwatch_log_group.app.name
}

output "app_cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for the application."
  value       = aws_cloudwatch_log_group.app.arn
}

output "sns_alarms_topic_arn" {
  description = "The ARN of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "sns_alarms_topic_name" {
  description = "The name of the SNS topic for alarms."
  value       = aws_sns_topic.alarms.name
}

output "cloudwatch_cpu_high_alarm_arn" {
  description = "The ARN of the CloudWatch alarm for high CPU utilization."
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cloudwatch_cpu_high_alarm_name" {
  description = "The name of the CloudWatch alarm for high CPU utilization."
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}
