variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, AWS Config)."
  default     = 365
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the database."
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create."
  default     = "mydb"
}

variable "db_username" {
  type        = string
  description = "The master username for the database."
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
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name for Terraform remote state."
  default     = "my-terraform-state-bucket"
}
