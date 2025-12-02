resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = "1.34"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [for s in aws_subnet.private : s.id]
    endpoint_private_access = var.enable_private_endpoint
    endpoint_public_access  = !var.enable_private_endpoint ? true : false
    # When public access is disabled, consider providing a bastion or SSM-based access path.
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_EKSServicePolicy
  ]
}

# After cluster creation we need to create the OIDC provider to allow IAM roles for service accounts (IRSA)
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_cert.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# TLS data required for the OIDC provider thumbprint
data "tls_certificate" "oidc_cert" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
