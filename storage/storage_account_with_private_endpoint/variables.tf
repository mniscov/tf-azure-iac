variable "storage_account_name" {
  type = string
}

variable "private_endpoint_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "storage_account_sku" {
  type    = string
  default = "Standard_LRS"
}

variable "storage_account_kind" {
  type    = string
  default = "StorageV2"
}
