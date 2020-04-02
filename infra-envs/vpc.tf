# Using the module from https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "meetup-vpc-${var.environment_name}"
  cidr = var.vpc_cidr

  azs = var.azs
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  public_subnets   = var.public_subnets

  # We want to share the NAT gateway in each AZ with all the private subnets
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_vpn_gateway = false
  enable_s3_endpoint = true
}
