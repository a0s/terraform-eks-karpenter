
data "aws_caller_identity" "current" {}

locals {
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
    {}
  )
}
