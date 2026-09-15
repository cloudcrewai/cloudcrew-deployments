variable "acm_domain_name" {
  type        = string
  description = "The domain name for the ACM certificate."
  default     = "example.com"
}

variable "app_domain_name" {
  type        = string
  description = "The application domain name."
  default     = "app.example.com"
}

variable "ecs_container_port" {
  type        = number
  description = "The port on which the ECS container listens."
  default     = 80
}

variable "ecs_cpu_alarm_comparison_operator" {
  type        = string
  description = "Comparison operator for the ECS CPU utilization alarm."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "ecs_cpu_alarm_threshold" {
  type        = number
  description = "CPU utilization percentage threshold for the ECS alarm."
  default     = 80
}

variable "ecs_cpu_target_utilization" {
  type        = number
  description = "Target CPU utilization percentage for ECS auto-scaling."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of tasks for the ECS service."
  default     = 3
}

variable "ecs_memory_alarm_comparison_operator" {
  type        = string
  description = "Comparison operator for the ECS memory utilization alarm."
  default     = "GreaterThanOrEqualToThreshold"
}

variable "ecs_memory_alarm_threshold" {
  type        = number
  description = "Memory utilization percentage threshold for the ECS alarm."
  default     = 80
}

variable "ecs_memory_target_utilization" {
  type        = number
  description = "Target memory utilization percentage for ECS auto-scaling."
  default     = 70
}

variable "ecs_min_capacity" {
  type        = number
  description = "The minimum number of tasks for the ECS service."
  default     = 1
}

variable "ecs_task_cpu" {
  type        = number
  description = "The CPU units for the ECS task (e.g., 256, 512, 1024)."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "The memory in MiB for the ECS task (e.g., 512, 1024, 2048)."
  default     = 512
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "health_check_path" {
  type        = string
  description = "The path for the application's health check."
  default     = "/health"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application and container logs."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-app"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "route53_hosted_zone" {
  type        = string
  description = "The Route53 hosted zone name for the application domain."
  default     = "example.com"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = "my-terraform-state-bucket"
}

variable "waf_rate_limit_threshold" {
  type        = number
  description = "The rate limit threshold for AWS WAF rules."
  default     = 2000
}
