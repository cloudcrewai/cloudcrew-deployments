terraform {
  backend "s3" {
    key     = "three-tier-web-app/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
