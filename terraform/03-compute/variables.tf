variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "The name of the project or application"
  default     = "my-application"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name for Terraform remote state"
  default     = ""
}
