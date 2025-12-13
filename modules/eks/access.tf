
data "aws_caller_identity" "current" {}

locals {
  # Generate access entries for additional ARNs
  additional_access_entries_map = {
    for idx, arn in var.user_access_entries : "access-entry-${replace(replace(arn, ":", "-"), "/", "-")}" => {
      kubernetes_groups = []
      principal_arn     = arn
      policy_associations = {
        namespace_user = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type       = "namespace"
            namespaces = var.user_access_allowed_namespaces
          }
        }
      }
    }
  }

  access_entries = merge(
    {
      terraform = {
        kubernetes_groups = []
        principal_arn     = data.aws_caller_identity.current.arn
        policy_associations = {
          full_admin = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    },
    local.additional_access_entries_map
  )
}
