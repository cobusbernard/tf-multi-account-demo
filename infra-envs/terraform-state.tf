terraform {
  backend "s3" {
    bucket  = "meetup-terraform-state"
    key     = "statefiles/environments"
    region  = "eu-west-1"
    profile = "meetup-main"
  }
}
