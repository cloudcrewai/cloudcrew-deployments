data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "prod-three-tier-web/production/01-networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "prod-three-tier-web/production/02-data/terraform.tfstate"
    region = "us-east-1"
  }
}
