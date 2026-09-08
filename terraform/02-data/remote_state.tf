data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "aurora-postgresql-cl/production/01-networking/terraform.tfstate"
    region = "us-east-1"
  }
}
