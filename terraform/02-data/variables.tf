variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "db_backup_retention_days" {
  type        = number
  description = "The number of days to retain backups for the database instance."
  default     = 7
}

variable "db_engine_version" {
  type        = string
  description = "The version of the database engine to use."
  default = "15.5"
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the database."
  default     = "db.t3.micro"
}

variable "db_storage_gb" {
  type        = number
  description = "The allocated storage in GB for the database instance."
  default     = 20
}

variable "db_username" {
  type        = string
  description = "Username for the database master user."
  default     = "admin"
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
  description = "The name of the project or application."
  default     = "my-application"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = "my-terraform-state-bucket"
}
