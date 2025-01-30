data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_recovery_services_vault" "bk-vault" {
  name                = "${var.resource_prefix}-vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.vault_sku
  public_network_access_enabled = var.public_network_access_enabled
  storage_mode_type   = var.storage_mode_type
}

resource "azurerm_backup_policy_vm" "daily-policy" {
  name                = "${var.resource_prefix}-vault-policy"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.bk-vault.name

  backup {
    frequency = var.backup_frequency
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }
}
