terraform {
  backend "s3" {
    key     = "microservices-platfo/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
