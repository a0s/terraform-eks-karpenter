output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.node_external.id
}

output "node_security_group_arn" {
  description = "Security group ARN attached to the EKS nodes"
  value       = aws_security_group.node_external.arn
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "auto_scaling_groups" {
  description = "Map of auto scaling group names by node group name"
  value = {
    karpenter         = try(module.eks.eks_managed_node_groups["karpenter"].node_group_autoscaling_group_names[0], null)
    karpenter_managed = try(module.eks.eks_managed_node_groups["karpenter_managed"].node_group_autoscaling_group_names[0], null)
  }
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

