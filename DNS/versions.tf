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
   assume_role {
    role_arn = "arn:aws:iam::${var.INSERT_DELEGATED_ACCOUNT_ID}:role/${var.INSERT_ASSUME_ROLE_NAME}"
    }
}