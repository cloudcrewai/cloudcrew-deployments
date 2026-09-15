terraform {
  backend "s3" {
    key     = "prod-three-tier-web/production/02-data/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
