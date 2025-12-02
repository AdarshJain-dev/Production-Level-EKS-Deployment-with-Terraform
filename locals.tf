locals {
  cluster_name      = var.cluster_name
  env               = var.environment
  name_prefix       = "${local.cluster_name}-${local.env}"
  azs               = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  common_tags = merge({
    Name        = local.name_prefix,
    Environment = local.env,
    Cluster     = local.cluster_name
  }, var.tags)
}
