module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "= 21.10.1"

  name               = var.cluster_name
  kubernetes_version = var.eks_version

  endpoint_public_access = true

  access_entries = local.access_entries

  addons = local.cluster_addons

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Disable EKS Auto Mode due to manual Karpenter management
  compute_config = {
    enabled = false
  }

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = [var.karpenter_node_group_instance_type]

      min_size     = var.karpenter_node_group_min_size
      max_size     = var.karpenter_node_group_max_size
      desired_size = var.karpenter_node_group_desired_size

      labels = {
        "karpenter.sh/controller" = "true"
      }
      vpc_security_group_ids = [aws_security_group.node_external.id]
    }
  }
}

resource "aws_security_group" "node_external" {
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

resource "aws_security_group_rule" "node_to_node" {
  for_each = toset(["ingress", "egress"])

  type                     = each.value
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node_external.id
  security_group_id        = aws_security_group.node_external.id
}

# Required for (AWS Load Balancer Controller, TargetGroupBinding, webhook)
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1828
resource "aws_security_group_rule" "ingress_rule" {
  type              = "ingress"
  from_port         = 9443
  to_port           = 9443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.node_external.id
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "= 21.10.1"

  cluster_name = module.eks.cluster_name

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

data "aws_ecrpublic_authorization_token" "token" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.cluster_name
}

provider "helm" {
  alias = "eks-module"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}

resource "helm_release" "karpenter" {
  provider            = helm.eks-module
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.8.3"
  wait                = true

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    webhook:
      enabled: false
    EOT
  ]
}

