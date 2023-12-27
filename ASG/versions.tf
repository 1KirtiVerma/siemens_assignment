terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  alias   = "delegated_account"
    assume_role {
    role_arn = "arn:aws:iam::<INSERT-DELEGATED-ACCOUNT-ID>:role/<INSERT-ASSUME-ROLE-NAME>"
    }
}