variable "subscription_id" {
  description = "Defines subscriptio id"
  type = string
  default = "5c6930fc-b1f9-4234-8e93-ca7bd89b77ca"
}

variable "vm_ids" {
  description = "List of Virtual Machine IDs to apply alerts to"
  type        = list(string)
  default     = []
}

variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "resource_prefix" {
  description = "A prefix to be used for naming resources (e.g., 'myapp')"
  type        = string
}

variable "short_name" {
  description = "Short name for the action group"
  type        = string
}

variable "enabled" {
  description = "Whether the action group is enabled"
  type        = bool
  default = true
}

variable "email_receivers" {
  description = "Email receivers for the action group"
  type = list(object({
    name          = string
    email_address = string
  }))
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "log_criteria" {
  type = map(object({
    name           = string
    description    = string
    category       = string
    operation_name = string
    resource_type  = string
  }))
  default = {
    "KVMOD" = {
      name           = "KVMOD"
      description    = "Keyvault: Modifying - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.KeyVault/vaults/write"
      resource_type  = "Microsoft.KeyVault/vaults"
    },
    "KVDEL" = {
      name           = "KVDEL"
      description    = "Keyvault: Deleting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.KeyVault/vaults/delete"
      resource_type  = "Microsoft.KeyVault/vaults"
    },
   "STORACCMOD" = {
      name           = "STORACCMOD"
      description    = "Storage Account: Modifying - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Storage/storageAccounts/write"
      resource_type  = "Microsoft.Storage/storageAccounts"
    },
    "STORACCDEL" = {
      name           = "STORACCDEL"
      description    = "Storage Account: Deleting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Storage/storageAccounts/delete"
      resource_type  = "Microsoft.Storage/storageAccounts"
    },    
    "VMSTOP" = {
      name           = "VMSTOP"
      description    = "Virtual Machines: Stopping - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Compute/virtualMachines/powerOff/action"
      resource_type  = "Microsoft.Compute/virtualMachines"
    },
    "VMRESTART" = {
      name           = "VMRESTART"
      description    = "Virtual Machines: Restarting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Compute/virtualMachines/restart/action"
      resource_type  = "Microsoft.Compute/virtualMachines"
    },
    "VMDEALL" = {
      name           = "VMDEALL"
      description    = "Virtual Machines: Deallocating - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
      resource_type  = "Microsoft.Compute/virtualMachines"
    },
    "VMDEL" = {
      name           = "VMDEL"
      description    = "Virtual Machines: Deleting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Compute/virtualMachines/delete"
      resource_type  = "Microsoft.Compute/virtualMachines"
    },
    "VMMTNCDEP" = {
      name           = "VMMTNCDEP"
      description    = "Virtual Machines: Maintenance Redeploy - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Compute/virtualMachines/performMaintenance/action"
      resource_type  = "Microsoft.Compute/virtualMachines"
    },
    "SUBNETMOD" = {
      name           = "SUBNETMOD"
      description    = "Subnets: Modifying - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Network/virtualNetworks/subnets/write"
      resource_type  = "Microsoft.Network/virtualNetworks/subnets"
    },
    "SUBNETDEL" = {
      name           = "SUBNETDEL"
      description    = "Subnets: Deleting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Network/virtualNetworks/subnets/write"
      resource_type  = "Microsoft.Network/virtualNetworks/subnets"
    },
    "LOCKDEL" = {
      name           = "LOCKDEL"
      description    = "Management locks: Deleting - please investigate"
      category       = "Administrative"
      operation_name = "Microsoft.Authorization/locks/delete"
      resource_type  = "Microsoft.Authorization/locks"
    }
  }
}

variable "custom_criteria" {
  description = "Additional custom criteria for the activity log alert"
  type = map(object({
    name           = string
    description    = string
    category       = string
    operation_name = string
    resource_type  = string
  }))
}

variable "webhook_properties" {
  description = "Webhook properties for the action"
  type        = map(string)
}

variable "enable_log_alert" {
  description = "Whether to enable the activity log alert"
  type        = bool
}
