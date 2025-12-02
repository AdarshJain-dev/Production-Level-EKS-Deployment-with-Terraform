############################################
# IAM Role for Bastion (SSM access only)
############################################

resource "aws_iam_role" "bastion_role" {
  name = "${local.name_prefix}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# Attach AmazonSSMManagedInstanceCore policy to enable SSM access
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile linking the IAM role
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.name_prefix}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

############################################
# Security Group for Bastion Host
# No SSH, ONLY SSM -> No inbound rules needed
############################################

# If you're using a vpc resource in this repo:
data "aws_vpc" "current" {
  id = aws_vpc.this.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "SG for bastion (SSM + allow internal VPC egress)"
  vpc_id      = aws_vpc.this.id  # or module.vpc.vpc_id if you use a module

  # If you intend to allow SSH from your IP (optional when using SSM)
  ingress {
    description = "SSH from admin IP (optional)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["106.207.220.197/32"]  # must be in CIDR format e.g. "X.Y.Z.W/32"
  }

  # Egress: allow all traffic to the VPC CIDR (enables reachability to private endpoints)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}


############################################
# Bastion EC2 Instance (SSM-enabled)
############################################

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type = "t3.micro"

  subnet_id              = element([for s in aws_subnet.public : s.id], 0)
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  # No SSH key needed
  key_name = null

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
  })
}

############################################
# Fetch Latest Amazon Linux 2 AMI
############################################

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
