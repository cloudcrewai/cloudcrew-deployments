variable "admin_email" {
  type        = string
  description = "Email address for administrative notifications."
  default     = "admin@example.com"
}

variable "cross_region_copy_destination" {
  type        = string
  description = "Destination region for cross-region resource copies (e.g., S3 bucket replication)."
  default     = ""
}

variable "db_identifier" {
  type        = string
  description = "Identifier for the database instance."
  default     = "my-app-db"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the application."
  default     = "example.com"
}

variable "ec2_ssm_instance_type" {
  type        = string
  description = "EC2 instance type for SSM-managed instances."
  default     = "t3.micro"
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of tasks for the ECS service."
  default     = 1
}

variable "ecs_task_cpu" {
  type        = number
  description = "CPU units for the ECS task (e.g., 256, 512, 1024)."
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "Memory (in MiB) for the ECS task (e.g., 512, 1024, 2048)."
  default     = 512
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "health_check_path" {
  type        = string
  description = "Path for the application's health check endpoint."
  default     = "/health"
}

variable "hosted_zone_name" {
  type        = string
  description = "The name of the Route 53 hosted zone for the domain."
  default     = "example.com."
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
  default     = 90
}

variable "pagerduty_endpoint" {
  type        = string
  description = "PagerDuty events API endpoint for sending alerts."
  default     = ""
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-application"
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
  description = "S3 bucket name for storing Terraform state."
  default     = ""
}
