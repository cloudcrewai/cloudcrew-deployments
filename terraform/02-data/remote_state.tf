data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = "aurora-serverless-v2/production/01-networking/terraform.tfstate"
    region = "us-east-1"
  }
}
