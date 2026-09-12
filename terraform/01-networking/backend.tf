terraform {
  backend "s3" {
    key     = "microservices-platfo/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
