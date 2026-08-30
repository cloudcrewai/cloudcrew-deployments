terraform {
  backend "s3" {
    key     = "ecs-microservices/prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
