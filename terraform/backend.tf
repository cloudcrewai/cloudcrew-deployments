terraform {
  backend "s3" {
    key     = "ecs-microservices/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
