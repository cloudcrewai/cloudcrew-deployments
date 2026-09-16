variable "api_gateway_custom_domain" {
  type        = string
  description = "Custom domain name for API Gateway."
  default     = ""
}

variable "audit_log_retention_days" {
  type        = number
  description = "Number of days to retain audit logs (e.g., CloudTrail, Config)."
  default     = 365
}

variable "cognito_user_pool_name" {
  type        = string
  description = "Name for the Cognito User Pool."
  default     = "my-app-user-pool"
}

variable "db_instance_class" {
  type        = string
  description = "DB instance class for the database."
  default     = "db.t3.micro"
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "hosted_zone" {
  type        = string
  description = "Route53 Hosted Zone name for custom domains."
  default     = ""
}

variable "kms_key_description" {
  type        = string
  description = "Description for the KMS key."
  default     = "KMS key for application data encryption"
}

variable "kms_key_enable_key_rotation" {
  type        = bool
  description = "Whether to enable automatic key rotation for the KMS key."
  default     = true
}

variable "lambda_api_handler_handler" {
  type        = string
  description = "The function entry point in your Lambda API handler code."
  default     = "index.handler"
}

variable "lambda_api_handler_memory_mb" {
  type        = number
  description = "Memory allocated to the Lambda API handler function in MB."
  default     = 128
}

variable "lambda_api_handler_runtime" {
  type        = string
  description = "Runtime for the Lambda API handler function."
  default     = "nodejs18.x"
}

variable "lambda_async_processor_handler" {
  type        = string
  description = "The function entry point in your Lambda async processor code."
  default     = "index.handler"
}

variable "lambda_async_processor_memory_mb" {
  type        = number
  description = "Memory allocated to the Lambda async processor function in MB."
  default     = 128
}

variable "lambda_async_processor_runtime" {
  type        = string
  description = "Runtime for the Lambda async processor function."
  default     = "nodejs18.x"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain application logs in CloudWatch."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "Name of the project, used for naming resources."
  default     = "my-project"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "secrets_manager_description" {
  type        = string
  description = "Description for the Secrets Manager secret."
  default     = "Application database credentials"
}

variable "sqs_dlq_message_retention_seconds" {
  type        = string
  description = "The number of seconds SQS retains a message in the Dead-Letter Queue."
  default     = 345600 # 4 days
}

variable "sqs_main_queue_delay_seconds" {
  type        = number
  description = "The length of time, in seconds, for which the delivery of all messages in the queue is delayed."
  default     = 0
}

variable "sqs_main_queue_max_message_size" {
  type        = string
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it."
  default     = 262144 # 256 KB
}

variable "sqs_main_queue_message_retention_seconds" {
  type        = string
  description = "The number of seconds SQS retains a message in the main queue."
  default     = 345600 # 4 days
}

variable "sqs_main_queue_receive_wait_time_seconds" {
  type        = number
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive."
  default     = 0
}

variable "sqs_main_queue_visibility_timeout_seconds" {
  type        = number
  description = "The length of time, in seconds, that a message received from a queue is hidden from subsequent retrieve requests."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform remote state."
  default     = ""
}

variable "log_bucket_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete audit-log buckets (CloudTrail access logs, AWS Config delivery) that still hold objects. Keep false to protect the audit trail; set true only for a deliberate teardown."
  default     = false
}
