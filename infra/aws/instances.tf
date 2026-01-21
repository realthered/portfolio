# Launch Template
resource "aws_launch_template" "portfolio_lt" {
  provider      = aws.ap-southeast-2
  name_prefix   = "${local.app_name}-lt-"
  image_id      = local.ami_id
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  iam_instance_profile {
    name = module.portfolio_ec2_iam_role.instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tpl", {
    app_name = local.app_name
    region = local.region
    eip_id = aws_eip.portfolio_eip.id
  }))

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "${local.app_name}-instance"
      Type = "Instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.tags, {
      Name = "${local.app_name}-volume"
      Type = "Volume"
    })
  }
}

# Auto Scaling Group with Mixed Instances Policy
resource "aws_autoscaling_group" "portfolio_asg" {
  provider            = aws.ap-southeast-2

  name                = "${local.app_name}-asg"
  vpc_zone_identifier = module.vpc.public_subnets
  min_size            = local.min_size
  max_size            = local.max_size
  desired_capacity    = local.desired_capacity

  health_check_type         = "EC2"
  health_check_grace_period = 300

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.portfolio_lt.id
        version            = "$Latest"
      }

      override {
        instance_type = local.instance_type
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 1  # First instance is on-demand
      on_demand_percentage_above_base_capacity = 0  # All instances above base are spot
    }
  }

  dynamic "tag" {
    for_each = merge(local.tags, {
      Name = "${local.app_name}-asg-instance"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
