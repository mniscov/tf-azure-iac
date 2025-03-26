variable "vmss_name" {
  description = "The name of the VMSS"
  type        = string
}

variable "location" {
  description = "The location for all resources"
  type        = string
}

variable "vm_size" {
  description = "The size of the VM instances"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "instance_count" {
  description = "Number of instances in the VMSS"
  type        = number
  default     = 0
}

variable "admin_username" {
  description = "The administrator username for the VM instances"
  type        = string
}

variable "admin_password" {
  description = "The administrator password for the VM instances"
  type        = string
  sensitive   = true
}

variable "image_publisher" {
  description = "The publisher of the image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "The offer of the image"
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "The SKU of the image"
  type        = string
  default     = "2019-Datacenter"
}

variable "image_version" {
  description = "The version of the image"
  type        = string
  default     = "latest"
}

variable "disk_size_gb" {
  description = "The size of the disk in GB"
  type        = number
  default     = 200
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "storage_account_sku" {
  description = "The SKU of the storage account"
  type        = string
  default     = "Standard_LRS"
}
