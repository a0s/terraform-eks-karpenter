variable "aws_region" {
  description = "AWS region where EKS cluster will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "karpenter_node_group_instance_type" {
  description = "Instance type for the Karpenter node group"
  type        = string
  default     = "t3.small"
}

variable "karpenter_node_group_ami_type" {
  description = "AMI type for the Karpenter node group"
  type        = string
  default     = "BOTTLEROCKET_x86_64"
}

variable "karpenter_node_group_min_size" {
  description = "Minimum number of nodes in the Karpenter node group"
  type        = number
  default     = 1
}

variable "karpenter_node_group_desired_size" {
  description = "Desired number of nodes in the Karpenter node group"
  type        = number
  default     = 2
}

variable "karpenter_node_group_max_size" {
  description = "Maximum number of nodes in the Karpenter node group"
  type        = number
  default     = 3
}

variable "addon_kube_proxy_enabled" {
  description = "Enable kube-proxy addon"
  type        = bool
  default     = true
}

variable "addon_kube_proxy_version" {
  description = "Version of the kube-proxy addon"
  type        = string
  default     = "v1.34.1-eksbuild.2"
}

variable "addon_coredns_enabled" {
  description = "Enable CoreDNS addon"
  type        = bool
  default     = true
}

variable "addon_coredns_version" {
  description = "Version of the CoreDNS addon"
  type        = string
  default     = "v1.12.4-eksbuild.1"
}

variable "addon_vpc_cni_enabled" {
  description = "Enable VPC CNI addon"
  type        = bool
  default     = true
}

variable "addon_vpc_cni_version" {
  description = "Version of the VPC CNI addon"
  type        = string
  default     = "v1.20.5-eksbuild.1"
}

variable "addon_pod_identity_agent_enabled" {
  description = "Enable EKS Pod Identity Agent addon"
  type        = bool
  default     = true
}

variable "addon_pod_identity_agent_version" {
  description = "Version of the EKS Pod Identity Agent addon"
  type        = string
  default     = "v1.3.10-eksbuild.1"
}

variable "metrics_server_enabled" {
  description = "Enable Metrics Server addon"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Version of the Metrics Server addon"
  type        = string
  default     = "v0.8.0-eksbuild.5"
}

variable "user_access_entries" {
  description = "List of ARNs (user or role ARNs) to grant cluster access with full admin policy"
  type        = list(string)
  default     = []
}

variable "user_access_allowed_namespaces" {
  description = "List of namespaces to grant cluster access with full admin policy"
  type        = list(string)
  default     = ["default"]
}
