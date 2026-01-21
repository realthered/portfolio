resource "azurerm_user_assigned_identity" "vmss_identity" {
  name                = "${local.app_name}-vmss-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.tags
}

resource "azurerm_role_assignment" "vmss_network_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.vmss_identity.principal_id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${local.app_name}-vmss"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = local.vm_size
  instances           = local.min_instances
  admin_username      = local.admin_username
  upgrade_mode        = "Automatic"

  admin_password = var.vmss_password

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${local.app_name}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.public.id
      public_ip_address {
        name = "${local.app_name}-vmss-pip"
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vmss_identity.id]
  }

  custom_data = base64encode(templatefile("${path.module}/userdata.sh.tpl", {
    app_name          = local.app_name
    resource_group    = azurerm_resource_group.main.name
    public_ip_name    = azurerm_public_ip.vmss_pip.name
    subscription_id   = var.subscription_id
  }))

  tags = merge(local.tags, {
    Name = "${local.app_name}-vmss-instance"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscale Setting
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${local.app_name}-autoscale"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "default"

    capacity {
      default = local.min_instances
      minimum = local.min_instances
      maximum = local.max_instances
    }
  }

  tags = local.tags
}
