terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

#########################################
# Refer to a resource group
#########################################
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

########################################
# Reference Azure Key Vault
########################################
data "azurerm_key_vault" "secretkv" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

######################################
# Reference Key Vault Secret
######################################
data "azurerm_key_vault_secret" "secret1" {
  name         = var.user
  key_vault_id = data.azurerm_key_vault.secretkv.id
}

#########################################
# Refer to a subnet
#########################################
data "azurerm_subnet" "vnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.rg_name
}

#########################################
# Create a network interface
#########################################
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.vm_name}-${count.index + 1}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_servers         = var.dns_servers

  ip_configuration {
    name                          = "${var.prefix}-${count.index + 1}-nic"
    subnet_id                     = data.azurerm_subnet.vnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

########################################################
# Create Linux Virtual Machine
########################################################
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "${var.vm_name}-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = data.azurerm_key_vault_secret.secret1.name
  admin_password        = data.azurerm_key_vault_secret.secret1.value
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  disable_password_authentication = var.disable_password_authentication
  tags = var.tags
 
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    name                 = "${var.vm_name}-${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.storageat
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }
}
