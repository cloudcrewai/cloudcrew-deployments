variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "audit_log_retention_days" {
  type    = number
  default = 365
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "project_name" {
  type    = string
  default = "my-app"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "root_volume_size" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = ""
}
