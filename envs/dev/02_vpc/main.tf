locals {
  _vpc_name     = "${var.env}-${var.random_suffix}"
  _cluster_name = "${var.env}-${var.random_suffix}"
}

module "vpc" {
  source          = "../../../modules/vpc"
  vpc_name        = local._vpc_name
  cluster_name    = local._cluster_name
  vpc_cidr        = "10.13.0.0/16"
  private_subnets = ["10.13.0.0/19", "10.13.32.0/19", "10.13.64.0/19"]
  public_subnets  = ["10.13.160.0/19", "10.13.192.0/19", "10.13.224.0/19"]
  nat_type        = "fck"
  fck_nat_name    = "fck-nat-${var.random_suffix}"
}
