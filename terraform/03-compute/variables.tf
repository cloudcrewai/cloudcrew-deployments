variable "audit_log_retention_days" {
  type    = number
  default = 365
}

variable "ecr_repository_name" {
  type    = string
  default = "sagemaker-inference-repo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "inference_initial_instance_count" {
  type    = number
  default = 1
}

variable "inference_instance_type" {
  type    = string
  default = "ml.t2.medium"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "project_name" {
  type    = string
  default = "sagemaker-project"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "sagemaker_log_group_name" {
  type    = string
  default = "/aws/sagemaker/Endpoint/my-sagemaker-endpoint"
}

variable "sagemaker_monitoring_image_uri" {
  type    = string
  default = ""
}

variable "sagemaker_monitoring_instance_type" {
  type    = string
  default = "ml.t2.medium"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = "my-sagemaker-tf-state"
}
