# Create OIDC provider for the cluster (we create after cluster resource) - placeholder here
# We'll use a small trick: create this once cluster is created using a null_resource or create conditionally.
# But Terraform resource aws_iam_openid_connect_provider requires the issuer URL, which EKS exposes only after cluster creation.
# To keep things simple in this repo: we create OIDC after cluster is created using data source (see eks-cluster.tf outputs)
