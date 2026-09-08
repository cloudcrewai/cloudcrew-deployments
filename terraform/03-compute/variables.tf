variable "audit_log_retention_days" {
  type    = number
  default = 365
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

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tf_state_bucket" {
  type    = string
  default = ""
}
