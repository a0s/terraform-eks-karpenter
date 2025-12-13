# Automate AWS EKS cluster setup with Karpenter, while utilizing Graviton and Spot instances

You've joined a new and growing startup.

The company wants to build its initial Kubernetes infrastructure on AWS. The team wants to leverage the latest autoscaling capabilities by Karpenter, as well as utilize Graviton and Spot instances for better price/performance.

They have asked you if you can help create the following:

1. Terraform code that deploys an EKS cluster (whatever latest version is currently available) into a new dedicated VPC

2. The terraform code should also deploy Karpenter with node pool(s) that can deploy both x86 and arm64 instances

3. Include a short readme that explains how to use the Terraform repo and that also demonstrates how an end-user (a developer from the company) can run a pod/deployment on x86 or Graviton instance inside the cluster.

**Deliverable**: A git repository containing all the necessary infrastructure as code needed in order to recreate a working POC of the above architecture. Your repository may be either public or private. If private please ensure to share it with the relevant reviewer.

## Highlights

- The _bootstrap stack is used only for managing the S3 bucket where Terraform stack states are stored. We create a private bucket for storing Terraform states with `force_destroy = true`. In a real project, this option should be disabled for additional bucket protection.

- We use symbolic link %stack_name%/_bootstrap.auto.tfvars -> 01_bootstrap/_main.auto.tfvars to use the same `env`, `random_suffix` and `aws_region` in every stack.
