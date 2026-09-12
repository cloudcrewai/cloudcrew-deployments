terraform {
  backend "s3" {
    key     = "microservices-platfo/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
