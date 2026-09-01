variable "alb_5xx_error_threshold" {
  type        = number
  description = "Threshold for ALB 5xx errors to trigger an alarm."
  default     = 5
}

variable "alb_health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
  default     = 3
}

variable "alb_health_check_interval" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target."
  default     = 30
}

variable "alb_health_check_matcher" {
  type        = string
  description = "The HTTP codes to use when checking for a successful response from a target."
  default     = "200"
}

variable "alb_health_check_path" {
  type        = string
  description = "The destination for the health check request."
  default     = "/"
}

variable "alb_health_check_port" {
  type        = string
  description = "The port to use to connect with the target."
  default     = "traffic-port"
}

variable "alb_health_check_timeout" {
  type        = number
  description = "The amount of time, in seconds, during which no response from a target means a failed health check."
  default     = 5
}

variable "alb_health_check_unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering a target unhealthy."
  default     = 3
}

variable "alb_name" {
  type        = string
  description = "Name for the Application Load Balancer."
  default     = ""
}

variable "alb_target_group_name" {
  type        = string
  description = "Name for the ALB Target Group."
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "The root domain name for the application."
  default     = "example.com"
}

variable "ecs_container_image" {
  type        = string
  description = "Docker image to deploy in the ECS container."
  default     = "nginx:latest"
}

variable "ecs_container_port" {
  type        = number
  description = "The port on the container that the application listens on."
  default     = 80
}

variable "ecs_cpu" {
  type        = number
  description = "The number of CPU units reserved for the container."
  default     = 256
}

variable "ecs_cpu_utilization_threshold" {
  type        = number
  description = "CPU utilization threshold for ECS service auto-scaling."
  default     = 70
}

variable "ecs_desired_count" {
  type        = number
  description = "The desired number of instantiations of the task definition to keep running on the service."
  default     = 1
}

variable "ecs_memory" {
  type        = number
  description = "The amount of memory (in MiB) reserved for the container."
  default     = 512
}

variable "ecs_service_name" {
  type        = string
  description = "Name for the ECS service."
  default     = ""
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)."
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch Log Groups."
  default     = 90
}

variable "project_name" {
  type        = string
  description = "The name of the project or application."
  default     = "my-app"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "us-east-1"
}

variable "route53_zone_name" {
  type        = string
  description = "The name of the Route53 hosted zone to manage DNS records."
  default     = "example.com"
}

variable "subdomain_name" {
  type        = string
  description = "The subdomain for the application (e.g., www, api)."
  default     = "www"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "tf_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for Terraform remote state."
  default     = ""
}
