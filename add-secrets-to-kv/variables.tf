variable "keyvault_name" {
  description = "Name of the existing Key Vault"
  type        = string
}

variable "keyvault_rg_name" {
  description = "The Resource Group of the Key Vault"
  type        = string
}

variable "kv_secrets" {
  description = "Secrets that need to be added"
  type        = map(string)
}
