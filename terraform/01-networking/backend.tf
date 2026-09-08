terraform {
  backend "s3" {
    key     = "aurora-postgresql-cl/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
