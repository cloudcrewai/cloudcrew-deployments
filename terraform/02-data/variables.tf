variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the database."
  default = "db.r6g.large"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create."
  default     = "mydb"
}

variable "db_preferred_backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if automated backups are enabled."
  default     = "03:00-05:00"
}

variable "db_preferred_maintenance_window" {
  type        = string
  description = "The weekly time range during which system maintenance can occur, in UTC."
  default     = "sun:04:00-sun:05:00"
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
  description = "Number of days to retain application and general logs."
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
  description = "A map of tags to assign to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name used for Terraform remote state."
  default     = "my-terraform-state-bucket"
}
