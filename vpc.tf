resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, { "Name" = "${local.name_prefix}-vpc" })
}

# Create public subnets (one per AZ)
resource "aws_subnet" "public" {
  for_each = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(local.public_subnet_cidrs, index(local.azs, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    "Name"                           = "${local.name_prefix}-public-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  })
}

# Create private subnets (one per AZ)
resource "aws_subnet" "private" {
  for_each = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(local.private_subnet_cidrs, index(local.azs, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    "Name"                                 = "${local.name_prefix}-private-${each.key}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  })
}
