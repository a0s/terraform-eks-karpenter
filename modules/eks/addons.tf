locals {
  addon_defaults = {
    "kube-proxy" = {
      enabled              = var.addon_kube_proxy_enabled
      version              = var.addon_kube_proxy_version
      resolve_conflicts    = "OVERWRITE"
      before_compute       = false
      configuration_values = null
    }
    "coredns" = {
      enabled              = var.addon_coredns_enabled
      version              = var.addon_coredns_version
      resolve_conflicts    = "OVERWRITE"
      before_compute       = false
      configuration_values = null
    }
    "vpc-cni" = {
      enabled           = var.addon_vpc_cni_enabled
      version           = var.addon_vpc_cni_version
      resolve_conflicts = "OVERWRITE"
      before_compute    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
        }
      })
    }
    "eks-pod-identity-agent" = {
      enabled              = var.addon_pod_identity_agent_enabled
      version              = var.addon_pod_identity_agent_version
      resolve_conflicts    = "OVERWRITE"
      before_compute       = true
      configuration_values = null
    }
    "metrics-server" = {
      enabled              = var.metrics_server_enabled
      version              = var.metrics_server_version
      resolve_conflicts    = "OVERWRITE"
      before_compute       = false
      configuration_values = null
    }
  }

  cluster_addons = {
    for addon_name, addon_config in local.addon_defaults : addon_name => merge(
      {
        resolve_conflicts = addon_config.resolve_conflicts
        addon_version     = addon_config.version
      },
      addon_config.before_compute ? { before_compute = true } : {},
      addon_config.configuration_values != null ? { configuration_values = addon_config.configuration_values } : {}
    ) if addon_config.enabled
  }
}
