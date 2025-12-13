
data "aws_availability_zones" "availability_zones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.availability_zones.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  intra_subnets   = var.intra_subnets

  enable_nat_gateway     = var.nat_type == "regular"
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  tags = merge({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }, var.tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }, var.tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    "karpenter.sh/discovery"                    = var.cluster_name
  }, var.tags)
}

module "fck_nat" {
  count  = var.nat_type == "fck" ? 1 : 0
  source = "git::https://github.com/RaJiska/terraform-aws-fck-nat.git"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]
  name      = var.fck_nat_name

  route_tables_ids = zipmap(
    ["0"],
    [module.vpc.private_route_table_ids[0]]
  )

  update_route_tables = true
  ha_mode             = true
  use_spot_instances  = true
}
