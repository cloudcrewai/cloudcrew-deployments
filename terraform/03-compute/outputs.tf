output "kms_ebs_key_arn" {
  description = "ARN of the KMS key for EBS encryption"
  value       = aws_kms_key.ebs.arn
}

output "kms_ebs_key_id" {
  description = "ID of the KMS key for EBS encryption"
  value       = aws_kms_key.ebs.key_id
}

output "kms_ebs_alias_name" {
  description = "Name of the KMS alias for EBS encryption"
  value       = aws_kms_alias.ebs.name
}

output "kms_logs_compute_key_arn" {
  description = "ARN of the KMS key for compute-specific CloudWatch Logs encryption"
  value       = aws_kms_key.logs_compute.arn
}

output "kms_logs_compute_key_id" {
  description = "ID of the KMS key for compute-specific CloudWatch Logs encryption"
  value       = aws_kms_key.logs_compute.key_id
}

output "kms_logs_compute_alias_name" {
  description = "Name of the KMS alias for compute-specific CloudWatch Logs encryption"
  value       = aws_kms_alias.logs_compute.name
}

output "ec2_instance_iam_role_arn" {
  description = "ARN of the IAM role for EC2 instances in the ASG"
  value       = aws_iam_role.ec2_instance.arn
}

output "ec2_instance_iam_role_name" {
  description = "Name of the IAM role for EC2 instances in the ASG"
  value       = aws_iam_role.ec2_instance.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile for the ASG"
  value       = aws_iam_instance_profile.ec2_instance.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile for the ASG"
  value       = aws_iam_instance_profile.ec2_instance.name
}

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = aws_launch_template.app.id
}

output "launch_template_arn" {
  description = "ARN of the EC2 Launch Template"
  value       = aws_launch_template.app.arn
}

output "launch_template_name" {
  description = "Name of the EC2 Launch Template"
  value       = aws_launch_template.app.name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "alb_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.bucket
}

output "alb_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for ALB access logs"
  value       = aws_s3_bucket.alb_logs.arn
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
  description = "Route 53 Hosted Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.app.arn
}

output "alb_target_group_name" {
  description = "Name of the ALB Target Group"
  value       = aws_lb_target_group.app.name
}

output "alb_https_listener_arn" {
  description = "ARN of the HTTPS listener for the ALB"
  value       = aws_lb_listener.https.arn
}

output "wafv2_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "wafv2_web_acl_id" {
  description = "ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_logs_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.name
}

output "waf_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for WAF logs"
  value       = aws_cloudwatch_log_group.waf_logs.arn
}

output "alarms_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}

output "alarms_sns_topic_name" {
  description = "Name of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.name
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.main.arn
}

output "config_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.bucket
}

output "config_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for AWS Config logs"
  value       = aws_s3_bucket.config_logs.arn
}

output "cloudtrail_logs_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_logs_s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudtrail_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail logs"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for CloudTrail logs"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_id" {
  description = "ID of the CloudTrail trail"
  value       = aws_cloudtrail.main.id
}
