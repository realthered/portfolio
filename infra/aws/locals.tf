locals {
  app_name         = "portfolio"
  environment      = "prod"
  region           = "ap-southeast-2"
  instance_type    = "t2.micro"
  ami_id           = "ami-0d6560f3176dc9ec0" # Amazon Linux 2023, ap-southeast-2 (Melbourne)
  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  tags = {
    Project   = "portfolio"
    Type      = "personal"
    Owner     = "nicolesjlee"
    Region    = "Sydney"
    Workspace = "realthered/portfolio/infra/aws"
  }
}
