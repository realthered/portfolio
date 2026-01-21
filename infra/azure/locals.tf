locals {
  app_name      = "portfolio"
  environment   = "prod"
  location      = "australiasoutheast"
  vm_size       = "Standard_B1s"
  min_instances = 1
  max_instances = 1
  admin_username = "azureuser"

  tags = {
    Project   = "portfolio"
    Owner     = "nicolesjlee"
    Region    = "Melbourne"
    Workspace = "realthered/portfolio/infra/azure"
  }
}
