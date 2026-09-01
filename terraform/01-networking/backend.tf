terraform {
  backend "s3" {
    key     = "ecs-microservices/prod/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
