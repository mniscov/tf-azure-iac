variable "image_publisher" {
  description = "The publisher of the image"
  type        = string
}

variable "image_offer" {
  description = "The offer of the image"
  type        = string
}

variable "image_sku" {
  description = "The SKU of the image"
  type        = string
}

variable "image_version" {
  description = "The version of the image"
  type        = string
}

variable "network_profile_name" {
  description = "The name of the network profile"
  type        = string
  default     = "vmss-network-profile"
}

variable "network_interface_name" {
  description = "The name of the network interface"
  type        = string
  default     = "primary-nic"
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration"
  type        = string
  default     = "internal"
}

variable "allocation_method" {
  description = "The allocation method for the public IP address"
  type        = string
  default     = "Dynamic"
}
