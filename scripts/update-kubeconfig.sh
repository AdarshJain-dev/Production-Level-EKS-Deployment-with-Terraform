#!/usr/bin/env bash
set -euo pipefail

REGION=${1:-ap-south-1}
CLUSTER=${2:-eks-prod-cluster}

aws eks --region "$REGION" update-kubeconfig --name "$CLUSTER"
echo "kubeconfig updated — you should now be able to run kubectl get nodes/pods from this host."
