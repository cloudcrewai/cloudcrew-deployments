terraform {
  backend "s3" {
    key     = "three-tier-web-app/production/03-compute/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
