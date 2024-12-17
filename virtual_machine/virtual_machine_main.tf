terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}
#########################################
# Configure the Microsoft Azure Provider
#########################################

#provider "azurerm" {
#  features {}
#  subscription_id = var.subscription_id
  #client_id = var.client_id
  #client_secret = var.client_secret
 # tenant_id = var.tenant_id
#}

########################################
# refer to a resource group
########################################

data "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}"
}

#######################################
# Reference Azure Key Vault
#######################################

data "azurerm_key_vault" "secretkv" {
  name                = var.keyvaultname
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
#refer to a subnet
#########################################

data "azurerm_subnet" "vnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.rg_name
}

#########################################
# create a network interface
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
#Create Virtual Machine
########################################################

resource "azurerm_windows_virtual_machine" "vm" {
  depends_on = [
    azurerm_network_interface.nic
  ]

  count                 = var.vm_count
  name                  = "${var.vm_name}-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = var.vm_size
  provision_vm_agent    = true
  admin_username        = data.azurerm_key_vault_secret.secret1.name
  admin_password        = data.azurerm_key_vault_secret.secret1.value
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${lower(var.vm_name)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = var.storageat
  }
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
}
