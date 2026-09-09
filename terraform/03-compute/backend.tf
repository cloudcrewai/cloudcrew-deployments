terraform {
  backend "s3" {
    key     = "aurora-postgresql-cl/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
