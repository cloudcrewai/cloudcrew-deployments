terraform {
  backend "s3" {
    key     = "aurora-postgres-prod/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
