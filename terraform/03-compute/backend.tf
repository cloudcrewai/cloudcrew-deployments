terraform {
  backend "s3" {
    key     = "ecs-microservices/prod/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
