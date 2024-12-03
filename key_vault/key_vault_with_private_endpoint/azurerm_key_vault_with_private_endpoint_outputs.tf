output "kv_name" {
  description = "The name assigned to the Key Vault"
  value       = azurerm_key_vault.key_vault.name
}

output "kv_id" {
  description = "The ID of the new the Key Vault"
  value       = azurerm_key_vault.key_vault.id
}