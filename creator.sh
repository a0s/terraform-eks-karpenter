#!/usr/bin/env bash
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}/envs/dev/01_bootstrap"
tofu init -upgrade
tofu apply -auto-approve

cd "${SCRIPT_DIR}/envs/dev/02_vpc"
tofu init -upgrade
tofu apply -auto-approve

cd "${SCRIPT_DIR}/envs/dev/03_eks"
tofu init -upgrade
tofu apply -auto-approve \
  -exclude="module.eks.helm_release.karpenter" \
  -exclude="module.eks.kubernetes_manifest.karpenter_nodepool_spot_arm64" \
  -exclude="module.eks.kubernetes_manifest.karpenter_nodepool_spot_amd64" \
  -exclude="module.eks.kubernetes_manifest.karpenter_ec2nodeclass_default"
tofu apply -auto-approve -target="module.eks.helm_release.karpenter"
tofu apply -auto-approve