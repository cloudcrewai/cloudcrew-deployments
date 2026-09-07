terraform {
  backend "s3" {
    key     = "ecs-microservices/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
