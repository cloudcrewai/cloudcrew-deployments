terraform {
  backend "s3" {
    key     = "three-tier-web-app/production/01-networking/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
