variable "acm_domain" {
  type        = string
  description = "The domain name for the ACM certificate."
  default     = ""
}

variable "app_port" {
  type        = number
  description = "The port on which the application listens."
  default     = 80
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "The maximum number of tasks for the ECS service auto-scaling."
  default     = 2
}

variable "ecs_task_cpu" {
  type    = string
  description = "The CPU units for the ECS task (e.g., '256', '512', '1024')."
  default     = "256"
}

variable "ecs_task_memory" {
  type    = string
  description = "The memory for the ECS task (e.g., '512', '1024', '2048')."
  default     = "512"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., 'dev', 'staging', 'prod')."
  default     = "dev"
}

variable "health_check_path" {
  type        = string
  description = "The path for the load balancer health check."
  default     = "/health"
}

variable "hosted_zone_name" {
  type        = string
  description = "The Route 53 hosted zone name for DNS records."
  default     = ""
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-app"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = ""
}
