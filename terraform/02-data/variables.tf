variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "ml-platform"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "s3_model_artifacts_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing ML model artifacts."
  default     = ""
}

variable "s3_training_data_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for storing ML training data."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for Terraform state."
  default     = ""
}
