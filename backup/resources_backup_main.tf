data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.resource_group_location
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
resource "azurerm_backup_protected_vm" "vm_backup" {
  for_each = { 
    for vm in azurerm_virtual_machine.this : vm.name => vm 
    if lookup(vm.tags, "backup", "no") == "yes" && lookup(vm.tags, "managedBy", "none") == "terraform"
  }

  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.bk-vault.name
  source_vm_id        = each.value.id
  backup_policy_id    = azurerm_backup_policy_vm.daily-policy.id
}


