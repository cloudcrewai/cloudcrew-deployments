terraform {
  backend "s3" {
    key     = "aurora-postgresql-cl/production/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
