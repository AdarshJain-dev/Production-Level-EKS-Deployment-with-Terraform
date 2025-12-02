provider "aws" {
  region = var.aws_region

  # If you use a role to perform terraform in CI, you can configure assume_role here:
  # assume_role {
  #   role_arn = var.terraform_assume_role_arn
  # }
}

# Optional: enable the Kubernetes provider later if you want Terraform to manage Helm/k8s manifests.
