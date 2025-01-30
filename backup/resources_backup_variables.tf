variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "resource_prefix" {
  description = "A prefix to be used for naming resources (e.g., 'myapp')"
  type        = string
}

variable "vault_sku" {
  description = "SKU of the recovery services vault"
  type        = string
  default     = "Standard"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = false
}

variable "storage_mode_type" {
  description = "Storage mode for the vault"
  type        = string
  default     = "LocallyRedundant"
}

variable "backup_frequency" {
  description = "Frequency of the backup (e.g., Daily)"
  type        = string
  default     = "Daily"
}

variable "backup_time" {
  description = "Time at which the backup will be taken"
  type        = string
  default     = "23:00"
}

variable "retention_daily_count" {
  description = "Number of daily backups to retain"
  type        = number
  default     = 7
}
