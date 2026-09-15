terraform {
  backend "s3" {
    key     = "three-tier-web-app/production/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
