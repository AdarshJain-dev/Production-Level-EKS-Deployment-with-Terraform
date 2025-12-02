# Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-rt" })
}

# Associate public route table to public subnets
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Create EIPs and NAT Gateway per AZ for HA (production)
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain = "vpc"
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-eip-${each.key}" })
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-nat-${each.key}" })
  depends_on = [aws_internet_gateway.igw]
}

# Private route tables: each private subnet -> corresponding NAT gateway
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    # Choose NAT in same AZ (match by index)
    nat_gateway_id = aws_nat_gateway.nat[element(keys(aws_subnet.public), index(keys(aws_subnet.private), each.key))].id
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-private-rt-${each.key}" })
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
