variable "api_domain_name" {
  type        = string
  description = "The domain name for the API Gateway custom domain."
  default     = ""
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table."
  default     = ""
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "hosted_zone_name" {
  type        = string
  description = "The name of the Route 53 hosted zone for the domain."
  default     = ""
}

variable "lambda_memory_mb" {
  type        = number
  description = "The amount of memory allocated to the Lambda function in MB."
  default     = 128
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime for the Lambda function."
  default     = "nodejs18.x"
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

variable "sqs_message_retention_days" {
  type        = number
  description = "The number of days to retain messages in the SQS queue."
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "The S3 bucket name for storing Terraform state."
  default     = ""
}
