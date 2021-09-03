terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "ke-terraform-backends"
    key = "state/startdust/sender_service.dev.tfstate"
    region = "eu-west-1"
    profile = "privateGmail"
  }
}