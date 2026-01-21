resource "aws_iam_policy" "portfolio_ec2_policy" {
  provider = aws.ap-southeast-2

  name        = "${local.app_name}-ec2-policy"
  description = "Policy to allow EC2 instances to associate Elastic IPs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:*Address", # Covers Describe, Associate
          "ec2:DescribeNetworkInterfaces",        ]
        Resource = "arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:*/*"
      }
    ]
  })
}

# IAM Role for EC2 to associate EIP
module "portfolio_ec2_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "${local.app_name}-ec2-assumeRole"

  create_instance_profile = true
  
  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ec2.amazonaws.com",
        ]
      }]
    }
  }

  policies = {
    portfolio_ec2_policy      = aws_iam_policy.portfolio_ec2_policy.arn
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-ec2-assumeRole"
    Type = "Role"
  })
}
