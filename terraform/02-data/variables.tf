variable "audit_log_retention_days" {
  type        = number
  description = "Retention period for audit logs in days."
  default     = 365
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones to deploy resources into."
  default = 2
}

variable "backup_plan_name" {
  type        = string
  description = "Name for the AWS Backup plan."
  default     = ""
}

variable "backup_selection_name" {
  type        = string
  description = "Name for the AWS Backup selection."
  default     = ""
}

variable "backup_vault_name" {
  type        = string
  description = "Name for the AWS Backup vault."
  default     = ""
}

variable "db_backup_retention_period" {
  type        = number
  description = "The number of days to retain automated backups for the DB instance."
  default     = 7
}

variable "db_cluster_identifier" {
  type        = string
  description = "Identifier for the DB cluster."
  default     = ""
}

variable "db_engine_version" {
  type        = string
  description = "The database engine version."
  default     = "14.7"
}

variable "db_instance_class" {
  type        = string
  description = "The instance type for the database."
  default     = "db.t3.medium"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create."
  default     = ""
}

variable "db_parameter_group_family" {
  type        = string
  description = "The DB parameter group family."
  default     = "postgres14"
}

variable "db_port" {
  type        = number
  description = "The port on which the database accepts connections."
  default     = 5432
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
  description = "Name of the S3 bucket used for Terraform state."
  default     = ""
}
