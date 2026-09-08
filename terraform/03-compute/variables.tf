variable "acm_certificate_domain" {
  type    = string
  default = ""
}

variable "ecr_image_name" {
  type    = string
  default = ""
}

variable "ecs_cpu" {
  type    = number
  default = 256
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "ecs_memory" {
  type    = number
  default = 512
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "project_name" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "secrets_manager_rotation_lambda_arn" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = ""
}
