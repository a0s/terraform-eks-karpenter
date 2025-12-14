# Automate AWS EKS cluster setup with Karpenter, while utilizing Graviton and Spot instances

Example Terraform project for deploying an AWS EKS cluster with Karpenter autoscaling, supporting both x86 and ARM64 (Graviton) instances.

## Features

- **EKS Cluster**: Deploys a production-ready EKS cluster in a dedicated VPC
- **Karpenter Integration**: Automated node provisioning with support for both x86 and ARM64 architectures
- **Cost Optimization**: Leverages Graviton and Spot instances for better price/performance
- **Multi-Architecture Support**: Run workloads on either x86 or ARM64 nodes based on pod requirements
- **Multiple Environments**: Supports creation of multiple environments (dev, prod, etc.)

## Highlights

- The `_bootstrap` stack is used only for managing the S3 bucket where Terraform stack states are stored. We create a private bucket for storing Terraform states with `force_destroy = true`. In a real project, this option should be disabled for additional bucket protection.

- We use symbolic links `%stack_name%/_bootstrap.auto.tfvars -> 01_bootstrap/_main.auto.tfvars` to use the same `env`, `random_suffix` and `aws_region` in every stack.

- Karpenter controller nodes are protected with a taint (`karpenter.sh/controller=true:NoSchedule`) to prevent other workloads from being scheduled on them. All system components (Karpenter, CoreDNS, EKS Pod Identity Agent, Metrics Server) have proper tolerations configured to run on these dedicated nodes.

- To create a second environment (e.g., `prod`), create a folder `envs/prod` and copy the contents from `envs/dev`. This content is a thin wrapper layer split into separate states (bootstrap, VPC, EKS) to reduce blast radius, and it uses modules from the `modules/` directory. After copying, update `_main.auto.tfvars` in `01_bootstrap` to set the correct `env`, `random_suffix`, and `aws_region` values for the new environment.

## Known Issues

- **Unexpected attribute error**: "An attribute named 'cluster_name' is not expected here"

  If you are using VSCode/CursorIDE together with OpenTofu (official) 0.6.0, it cannot (presumably) correctly parse the Karpenter submodule when it is called from your module.
