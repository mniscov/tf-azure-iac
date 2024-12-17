terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = var.purgedelete
      recover_soft_deleted_key_vaults = var.recover
    }
  }
}

data "azurerm_client_config" "current" {
}

########################################################################################################################
# Creates a New KeyVault & Private Endpoint
########################################################################################################################
# Deploy the KeyVault
resource "azurerm_key_vault" "key_vault" {
  name                        = var.kv_config.name
  location                    = var.kv_config.location
  resource_group_name         = var.kv_config.resource_group_name
  sku_name                    = var.kv_config.sku_name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption ###
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = var.public_network_access ###
  soft_delete_retention_days = var.kv_config.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled ###
  enable_rbac_authorization  = var.enable_rbac_authorization ###
  tags                       = var.tags


  network_acls {
    default_action = var.kv_default_action
    bypass         = "AzureServices"
    ip_rules       = var.kv_allowed_cidr
  }
}


################################################################################
# Create a new Private Endpoint - Optional
################################################################################
resource "azurerm_private_endpoint" "pe" {
  count               = var.pe_name == "" ? 0 : 1
  name                = var.pe_name
  location            = var.kv_config.location
  resource_group_name = var.kv_config.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.kv_config.name}-pep"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

################################
# Create Role Assignments
################################
locals {
  principal_roles_list = flatten([ # Produce a list object, containing mapping of role names to principal IDs.
    for role, principals in var.role_assignments : [
      for principal in principals : {
        role      = role
        principal = principal
      }
    ]
  ])

  principal_roles_tuple = {
    for obj in local.principal_roles_list : "${obj.role}_${obj.principal}" => obj
  }

  principal_roles_map = tomap(local.principal_roles_tuple)

}

resource "azurerm_role_assignment" "role_assignments" {
  for_each             = local.principal_roles_map
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal
  depends_on = [azurerm_key_vault.key_vault]
}
