output "secrets" {
  description = "Creates secrets"
  value = {
    for name, secret in azurerm_key_vault_secret.kv_secrets :
    name => secret.id
  }
}
