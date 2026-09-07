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

variable "db_apply_immediately" {
  type        = bool
  description = "Whether any modifications to the DB instance are applied immediately, or during the next maintenance window."
  default     = false
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the RDS database."
  default     = "db.t3.micro"
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

variable "db_username" {
  type        = string
  description = "Username for the RDS database."
  default     = "admin"
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod)."
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
  description = "AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform state."
  default     = "my-terraform-state-bucket"
}
