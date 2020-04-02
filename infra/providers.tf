provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
  profile = "meetup-main"
}

provider "template" {
  version = "~> 2.1"
}