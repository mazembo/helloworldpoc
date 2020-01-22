terraform {
  backend "s3" {
    bucket = "dev-ontology-terraform"
    key    = "terraform/ontology-terraform.tfstate"
    region = "eu-west-3"
  }
}


# Configure the AWS Provider
provider "aws" {
#   profile = "default"
  version = "~> 2.0"
  region  = var.region

  assume_role {
    role_arn     = "arn:aws:iam::717206073145:role/Administrators"
  }
}

