variable "app_port" {
  type    = number
  default = 80
}

variable "asg_target_cpu_utilization" {
  type    = number
  default = 70
}

variable "cpu_alarm_evaluation_periods" {
  type    = number
  default = 2
}

variable "cpu_alarm_period" {
  type    = number
  default = 300
}

variable "cpu_alarm_threshold" {
  type    = number
  default = 80
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "health_check_healthy_threshold" {
  type    = number
  default = 3
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_matcher" {
  type    = string
  default = "200"
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}

variable "health_check_timeout" {
  type    = number
  default = 5
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "max_size" {
  type    = number
  default = 3
}

variable "min_size" {
  type    = number
  default = 1
}

variable "project_name" {
  type    = string
  default = "my-project"
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
