resource "azurerm_virtual_machine_scale_set" "example" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  sku {
    name     = var.vm_size
    capacity = var.instance_count
  }

  upgrade_policy_mode = "Manual"

  os_profile {
    computer_name_prefix = "vmss"
    admin_username       = var.admin_username
    admin_password       = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_profile {
    image_reference {
      publisher = var.image_publisher
      offer     = var.image_offer
      sku       = var.image_sku
      version   = var.image_version
    }
  }

  network_profile {
    name    = var.network_profile_name
    primary = true
    network_interface {
      name    = var.network_interface_name
      primary = true
      ip_configuration {
        name                                   = var.ip_configuration_name
        subnet_id                              = data.azurerm_subnet.existing_subnet.id
        private_ip_address_allocation          = "Dynamic"
        public_ip_address_configuration {
          allocation_method = var.allocation_method
        }
      }
    }
  }
}
