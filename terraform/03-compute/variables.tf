variable "alb_5xx_error_threshold" {
  type        = number
  description = "Threshold for ALB 5xx errors to trigger an alarm."
  default     = 5
}

variable "app_image_tag" {
  type        = string
  description = "Docker image tag for the application."
  default     = "latest"
}

variable "app_port" {
  type        = number
  description = "Port on which the application listens."
  default     = 80
}

variable "domain_name" {
  type        = string
  description = "Domain name for the application's public endpoint."
  default     = ""
}

variable "ecs_cpu_utilization_threshold" {
  type        = number
  description = "CPU utilization percentage threshold for ECS scaling."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "Maximum number of tasks for the ECS service."
  default     = 3
}

variable "ecs_min_capacity" {
  type        = number
  description = "Minimum number of tasks for the ECS service."
  default     = 1
}

variable "ecs_target_cpu_utilization" {
  type        = number
  description = "Target CPU utilization percentage for ECS auto-scaling."
  default     = 70
}

variable "ecs_task_cpu" {
  type        = number
  description = "CPU units for the ECS task (e.g., 256 for 0.25 vCPU)."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "Memory (in MiB) for the ECS task."
  default     = 512
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "health_check_path" {
  type        = string
  description = "Path for the application's health check endpoint."
  default     = "/health"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project or application."
  default     = "my-app"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform state."
  default     = ""
}
