terraform {
  backend "s3" {
    key     = "microservices-platfo/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
