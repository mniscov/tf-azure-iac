variable "kv_config" {
  type = object({
    name                       = string
    location                   = string
    resource_group_name        = string
    sku_name                   = string
    soft_delete_retention_days = string
  })
}

variable "purgedelete" {
  type        = bool
  description = "purge soft delete on destroy"
}

variable "recover" {
  type        = bool
  description = "recover soft deleted key vaults"
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys"
}

variable "public_network_access" {
  type        = bool
  description = "Whether public network access is allowed for this Key Vault."
  default = false
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Is Purge Protection enabled for this Key Vault"
  default = true
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  default = true
}

variable "kv_default_action" {
  description = "The Default Action to use when theres no match to the IP Rules. Possible values are Allow and Deny."
  type        = string
  default     = "Deny"
}

variable "kv_allowed_cidr" {
  description = <<EOF
  One or more IP addresses (in CIDR notation) that can access the KeyVault.
  EXAMPLE:
  kv_allowed_cidr = ["77.66.55.0/24","21.22.23.0/18"]
EOF
  type        = list(string)
  default     = []
}

variable "role_assignments" {
  type        = any
  default     = {}
  description = <<EOF
    "Define a map of Roles (either Custom or Built-In) to Princpal IDs, scoped to the new Key Vault.
    EXAMPLE:
    role_assignments = {
        Secrets_User    = ["sfdsf", "fdsdvfsa"],
        Secrets_Officer = ["esrewfds", "wefsdsd"]
        Contributor     = ["879y9-ugbi", "iuhi39hy98hd"]
    }
EOF
}


# OPTIONAL
variable "pe_name" {
  type        = string
  description = "The name to assign to the Key vault Private Endpoint. Private Endpoint will NOT be deployed if this is not defined."
  default     = ""
}

variable "pe_subnet_id" {
  description = "The ID of the Azure Subnet where the new private Endpoint for the Key vault will be created."
  type        = string
  default     = ""
}

variable "private_vault_dns_zone_name" {
  description = "The name of the Private DNS zone for Private Endpoint"
  type        = string
  default     = ""
}

variable "private_vault_dns_zone_ids" {
  description = "The ID of the Private DNS zone for Private Endpoint"
  type        = list(string)
  default     = []
}


variable "tags" {
  description = "A map of tags to be assigned to the new resource"
  type        = map(string)
  default     = {}
}