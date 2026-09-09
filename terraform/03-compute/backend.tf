terraform {
  backend "s3" {
    key     = "three-tier-web-app/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
