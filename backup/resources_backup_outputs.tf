output "recovery_vault_id" {
  description = "The ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.bk-vault.id
}

output "backup_policy_name" {
  description = "The name of the backup policy"
  value       = azurerm_backup_policy_vm.daily-policy.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.rg.name
}
