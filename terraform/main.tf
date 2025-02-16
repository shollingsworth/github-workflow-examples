terraform {
  backend "s3" {
    # change this to suite your needs
    profile        = "personal"
    key            = "github-workflow-examples/terraform.tfstate"
    bucket         = "shollingsworth-terraform-tfstate"
    region         = "us-east-2"
    dynamodb_table = "shollingsworth-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = "personal"
  region  = "us-east-2"
  default_tags {
    tags = {
      source_control = local.source_control
      owner          = local.owner
    }
  }
}
