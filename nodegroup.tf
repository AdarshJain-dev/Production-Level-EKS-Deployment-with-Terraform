resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name_prefix}-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  instance_types = var.node_instance_types

  capacity_type = "ON_DEMAND"

  # Recommend not enabling SSH via key when using SSM; leave remote_access unset or set to SSM later
  remote_access {
    #ec2_ssh_key = var.ssh_key_name
    #source_security_group_ids = [aws_security_group.bastion.id]
    # Note: if you leave ec2_ssh_key blank, nodes won't have SSH key added (more secure).
  }

  force_update_version = true

  tags = merge(local.common_tags, {
    "Name" = "${local.name_prefix}-nodegroup"
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_ssm
  ]
}
