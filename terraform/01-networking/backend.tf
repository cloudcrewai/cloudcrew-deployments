terraform {
  backend "s3" {
    key     = "aurora-postgres-prod/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
