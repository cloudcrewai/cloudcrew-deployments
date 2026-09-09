variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
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

variable "sagemaker_initial_instance_count_inference" {
  type        = number
  description = "The initial number of instances for SageMaker inference endpoint."
  default     = 1
}

variable "sagemaker_instance_type_inference" {
  type        = string
  description = "The instance type for SageMaker inference endpoint."
  default     = "ml.t2.medium"
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
