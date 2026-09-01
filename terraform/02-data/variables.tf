variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to deploy resources into."
  default = 2
}

variable "db_instance_class" {
  type        = string
  description = "The instance type for the database."
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "The name of the database."
  default     = "mydb"
}

variable "db_username" {
  type        = string
  description = "The master username for the database."
  default     = "admin"
}

variable "elasticache_node_type" {
  type        = string
  description = "The node type for the ElastiCache cluster."
  default     = "cache.t3.micro"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for application and general logs in days."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "my-project"
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
  description = "The S3 bucket name for Terraform remote state."
  default     = "my-project-tf-state-bucket"
}
