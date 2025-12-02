# Security Group for EKS worker nodes
resource "aws_security_group" "nodes" {
  name        = "${local.name_prefix}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nodes-sg" })

  # allow all traffic inside the SG (node-to-node, pod-to-pod)
  ingress {
    description = "Allow all within SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # allow node->control plane (EKS control plane uses ENIs in subnets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_api_access_from_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

