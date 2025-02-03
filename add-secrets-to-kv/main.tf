terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.49.0"
    }
  }
}
provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "existing_kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg_name
}

resource "azurerm_key_vault_secret" "kv_secrets" {
  for_each     = var.kv_secrets
  name         = "${each.key}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  value        = each.value
  key_vault_id = data.azurerm_key_vault.existing_kv.id

  expiration_date = formatdate("YYYY-MM-DD'T'HH:mm:ss'Z'", timeadd(timestamp(), "72h"))

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [value]
  }
}
