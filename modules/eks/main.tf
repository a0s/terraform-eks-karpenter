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

  security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

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
      taints = {
        karpenter_controller = {
          key    = "karpenter.sh/controller"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
      vpc_security_group_ids = [aws_security_group.node_external.id]
    }
  }
}

resource "aws_security_group" "node_external" {
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id
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
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.cluster_name
}

data "aws_ecrpublic_authorization_token" "token" {}

provider "helm" {
  alias = "eks-module"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
  registries = [{
    url      = "oci://public.ecr.aws"
    username = data.aws_ecrpublic_authorization_token.token.user_name
    password = data.aws_ecrpublic_authorization_token.token.password
  }]
}

resource "helm_release" "karpenter" {
  provider   = helm.eks-module
  namespace  = "kube-system"
  name       = "karpenter"
  chart      = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version    = "1.8.3"
  wait       = true

  values = [
    <<-EOT
    tolerations:
      - key: "karpenter.sh/controller"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

resource "kubernetes_manifest" "karpenter_nodepool_spot_arm64" {
  depends_on = [helm_release.karpenter]
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "spot-arm64"
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "0s"
      }
      template = {
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["arm64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values = [
                "c6g",
                "m6g",
              ]
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values   = ["1", "2", "4"]
            },
            {
              key      = "karpenter.k8s.aws/instance-hypervisor"
              operator = "In"
              values   = ["nitro"]
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values   = ["2"]
            }
          ]
          expireAfter            = "168h"
          terminationGracePeriod = "5m"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_nodepool_spot_amd64" {
  depends_on = [helm_release.karpenter]
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "spot-amd64"
    }
    spec = {
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "0s"
      }
      template = {
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values = [
                "c6a",
                "m6a",
              ]
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values   = ["1", "2", "4"]
            },
            {
              key      = "karpenter.k8s.aws/instance-hypervisor"
              operator = "In"
              values   = ["nitro"]
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values   = ["2"]
            }
          ]
          expireAfter            = "168h"
          terminationGracePeriod = "5m"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass_default" {
  depends_on = [helm_release.karpenter]
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiSelectorTerms = [
        {
          alias = "bottlerocket@latest"
        }
      ]
      role = module.karpenter.node_iam_role_name
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      tags = {
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
  }
}
