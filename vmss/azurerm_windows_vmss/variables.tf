variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "vnet_name" {
  description = "The name of the existing virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the existing subnet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "The address prefix of the subnet"
  type        = list(string)
}

variable "vmss_name" {
  description = "The name of the virtual machine scale set"
  type        = string
}

variable "vmss_sku" {
  description = "The SKU of the virtual machine scale set"
  type        = string
}

variable "vmss_instances" {
  description = "The number of instances in the virtual machine scale set"
  type        = number
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "computer_name_prefix" {
  description = "The prefix for the computer names in the scale set"
  type        = string
}

variable "image_publisher" {
  description = "The publisher of the virtual machine image"
  type        = string
}

variable "image_offer" {
  description = "The offer of the virtual machine image"
  type        = string
}

variable "image_sku" {
  description = "The SKU of the virtual machine image"
  type        = string
}

variable "image_version" {
  description = "The version of the virtual machine image"
  type        = string
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk"
  type        = string
}

variable "os_disk_caching" {
  description = "The caching setting for the OS disk"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration for the network interface"
  type        = string
}
