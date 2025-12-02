data "aws_availability_zones" "available" {
  state = "available"
}

# EKS AMI can be left default; EKS will pick optimized AMI for the node group.
# If needed, add data source to fetch latest EKS-optimized AMI (left out here to let AWS pick).
