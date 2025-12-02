variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-prod-cluster"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "node_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 4
}
variable "node_desired_size" {
  type    = number
  default = 2
}

variable "ssh_key_name" {
  description = "SSH keypair name (optional) - recommended: leave blank and use SSM"
  type        = string
  default     = ""
}

variable "enable_private_endpoint" {
  description = "Set true to make EKS API accessible only inside VPC (recommended for prod)"
  type        = bool
  default     = true
}

variable "admin_role_arns" {
  description = "List of IAM role ARNs that should be granted system:masters (use sparingly)"
  type        = list(string)
  default     = []
}

# Placeholders for naming resources and tags
variable "tags" {
  type = map(string)
  default = {
    Owner = "devops"
    Team  = "platform"
  }
}
