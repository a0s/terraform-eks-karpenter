data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-${var.env}-${var.random_suffix}"
    key    = "${var.env}/vpc/terraform.tfstate"
    region = var.aws_region
  }
}

module "eks" {
  source         = "../../../modules/eks"
  aws_region     = var.aws_region
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  subnet_ids     = data.terraform_remote_state.vpc.outputs.private_subnets
  cluster_name   = data.terraform_remote_state.vpc.outputs.cluster_name
  eks_version    = "1.34"

  # karpenter_node_group_desired_size = 1
}

data "aws_caller_identity" "current" {}

locals {
  kubeconfig_token = templatefile("${path.module}/kubeconfigToken.tpl", {
    certificate_authority_data = module.eks.cluster_certificate_authority_data
    server                     = module.eks.cluster_endpoint
    cluster                    = module.eks.cluster_name
    user                       = "${module.eks.cluster_name}-user"
    context                    = "${module.eks.cluster_name}-context"
    aws_region                 = var.aws_region
    aws_cluster_name           = module.eks.cluster_name
  })
}

resource "local_file" "kubeconfig" {
  content  = local.kubeconfig_token
  filename = "${path.root}/../../../${var.env}.kubeconfig.yaml"
}
