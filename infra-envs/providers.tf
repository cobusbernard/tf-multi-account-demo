provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
  profile = "meetup-main"
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/AdminOrgRole"
    session_name = "terraform"
  }
}

provider "template" {
  version = "~> 2.1"
}