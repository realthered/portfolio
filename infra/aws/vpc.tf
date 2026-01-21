# Data source for availability zones
data "aws_availability_zones" "available" {
  provider = aws.ap-southeast-2

  state = "available"
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.ap-southeast-2
  }

  name = "${local.app_name}-vpc"
  cidr = "10.0.20.0/24"

  azs             = slice(data.aws_availability_zones.available.names, 0, 1)
  public_subnets  = ["10.0.20.0/26", "10.0.20.64/26"]
  private_subnets = ["10.0.20.128/26", "10.0.20.192/26"]

  create_igw = true
  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    Name = "${local.app_name}-public-subnet"
  }

  vpc_tags = merge(local.tags, {
    Name = "${local.app_name}-vpc"
  })
}

# Security Group
resource "aws_security_group" "asg_sg" {
  provider = aws.ap-southeast-2

  name        = "${local.app_name}-asg-sg"
  description = "Security group for ${local.app_name} ASG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-asg-sg"
  })
}

# Elastic IP for ASG instances
resource "aws_eip" "portfolio_eip" {
  provider = aws.ap-southeast-2
  domain   = "vpc"

  tags = merge(local.tags, {
    Name = "${local.app_name}-eip"
  })
}
