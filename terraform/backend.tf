terraform {
  backend "s3" {
    key     = "aurora-postgres-prod/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
