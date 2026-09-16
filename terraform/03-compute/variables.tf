variable "api_gateway_custom_domain" {
  type        = string
  description = "Custom domain name for API Gateway."
  default     = ""
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "hosted_zone_name" {
  type        = string
  description = "The name of the Route 53 Hosted Zone to create DNS records in."
  default     = ""
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project, used for resource naming and tagging."
  default     = "my-project"
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
  description = "Name of the S3 bucket used for Terraform state."
  default     = ""
}
