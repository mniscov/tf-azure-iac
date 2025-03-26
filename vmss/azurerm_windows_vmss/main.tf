data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "internal" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
}

resource "azurerm_windows_virtual_machine_scale_set" "example" {
  name                 = var.vmss_name
  resource_group_name  = data.azurerm_resource_group.example.name
  location             = data.azurerm_resource_group.example.location
  sku                  = var.vmss_sku
  instances            = var.vmss_instances
  admin_password       = var.admin_password
  admin_username       = var.admin_username
  computer_name_prefix = var.computer_name_prefix

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_caching
    disk_size_gb         = var.os_disk_size_gb
   }

  network_interface {
    name    = var.network_interface_name
    primary = true

    ip_configuration {
      name      = var.ip_configuration_name
      primary   = true
      subnet_id = data.azurerm_subnet.internal.id
    }
  }
  tags = var.tags
}
