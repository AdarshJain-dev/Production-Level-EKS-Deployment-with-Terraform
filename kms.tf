resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secrets and EBS encryption"
  deletion_window_in_days = 30

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-kms" })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name_prefix}-eks"
  target_key_id = aws_kms_key.eks.id
}
