#!/usr/bin/env bash
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}/envs/dev"

cd "${SCRIPT_DIR}/envs/dev/03_eks"
tofu destroy -auto-approve -target="module.eks.helm_release.karpenter" || true
tofu destroy -auto-approve || true

cd "${SCRIPT_DIR}/envs/dev/02_vpc"
tofu destroy -auto-approve || true

cd "${SCRIPT_DIR}/envs/dev/01_bootstrap"
tofu destroy -auto-approve || true