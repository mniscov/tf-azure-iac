provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "existing_kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg_name
}

resource "azurerm_key_vault_secret" "kv_secrets" {
  for_each     = var.kv_secrets
  name         = each.key
  value        = each.value
  key_vault_id = data.azurerm_key_vault.existing_kv.id

  attributes {
    expires = timeadd(timestamp(), "720h")
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
