variable "subscription_id" {
  type        = string
  description = "Existing VM subscription ID"
}

variable "tenant_id" {
  type        = string
  default     = "1878a48b-63d6-4d12-a900-07d4267f6762"
  description = "Tenant ID phoenixonline"
}

variable "rg_name" {
  type        = string
  description = "name of your resource group"

}
variable "location" {
  default     = "westeurope"
  description = "location of your resource group"
}

variable "prefix" {
  type        = string
  description = "Prefix for the virtual machine"
}

variable "vm_name" {
  type        = string
  description = "virtual machine name"
}

variable "vnet-rg" {
  type        = string
  description = "Existing virutal network resource group"
}

variable "vnet" {
  type        = string
  description = "Existing virutal network"
}
variable "subnet" {
  type        = string
  description = "Existing virutal network subnet name"
}

variable "publisher" {
  type        = string
  description = "Name of OS publisher"
}

variable "offer" {
  type        = string
  description = "Name of OS offer e.g. office-365"
}

variable "sku" {
  type        = string
  description = "OS sku"
}

variable "storageat" {
  type        = string
  description = "Storage Account type"
}

variable "vm_count" {
  type        = number
  description = "Number of virtual machines to deploy"
}

variable "vm_size" {
  type        = string
  description = "Size of the machine to deploy"
}

variable "dns_servers" {
  description = "On-premise DNS Server"
  default     = ["10.156.70.11", "10.156.70.13"]
}
variable "disable_password_authentication" {
  type        = bool
  description = "Flag to disable password authentication for Linux VMs"
  default     = false
}
variable "user" {
  type        = string
  default     = "admin"
  description = "Local administrator account"
}
variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
  default     = {}
}
