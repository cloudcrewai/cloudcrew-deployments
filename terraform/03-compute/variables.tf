variable "alb_ssl_policy" {
  type        = string
  description = "The SSL policy for the ALB listener."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "app_health_check_path" {
  type        = string
  description = "The path for the application health check."
  default     = "/health"
}

variable "app_port" {
  type        = number
  description = "The port on which the application listens."
  default     = 80
}

variable "db_username" {
  type        = string
  description = "Username for the database."
  default     = "admin"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application."
  default     = ""
}

variable "ecs_cpu_alarm_threshold" {
  type        = number
  description = "CPU utilization threshold for ECS service alarm (percentage)."
  default     = 80
}

variable "ecs_cpu_target_utilization" {
  type        = number
  description = "Target CPU utilization for ECS service autoscaling (percentage)."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of tasks for the ECS service autoscaling."
  default     = 3
}

variable "ecs_min_capacity" {
  type        = number
  description = "The minimum number of tasks for the ECS service autoscaling."
  default     = 1
}

variable "ecs_task_cpu" {
  type        = number
  description = "The CPU units for the ECS task (e.g., 256 for 0.25 vCPU)."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "The memory in MiB for the ECS task."
  default     = 512
}

variable "elasticache_cpu_alarm_threshold" {
  type        = number
  description = "CPU utilization threshold for ElastiCache alarm (percentage)."
  default     = 70
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "kms_alb_logs_description" {
  type        = string
  description = "Description for the KMS key used for ALB access logs."
  default     = "KMS key for ALB access logs"
}

variable "kms_app_description" {
  type        = string
  description = "Description for the KMS key used for application data encryption."
  default     = "KMS key for application data encryption"
}

variable "kms_cloudwatch_logs_description" {
  type        = string
  description = "Description for the KMS key used for CloudWatch Logs encryption."
  default     = "KMS key for CloudWatch Logs encryption"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-app"
}

variable "rds_cpu_alarm_threshold" {
  type        = number
  description = "CPU utilization threshold for RDS instance alarm (percentage)."
  default     = 70
}

variable "rds_free_storage_alarm_threshold_bytes" {
  type        = string
  description = "Free storage threshold for RDS instance alarm (bytes)."
  default     = 10737418240 # 10 GB
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "secrets_manager_description" {
  type        = string
  description = "Description for the Secrets Manager secret."
  default     = "Secrets Manager secret for application credentials"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name for Terraform remote state."
  default     = "my-terraform-state-bucket"
}

variable "waf_scope" {
  type        = string
  description = "The scope of the WAF Web ACL (CLOUDFRONT or REGIONAL)."
  default     = "REGIONAL"
}
