terraform {
  backend "s3" {
    key     = "prod-three-tier-web/production/03-compute/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
