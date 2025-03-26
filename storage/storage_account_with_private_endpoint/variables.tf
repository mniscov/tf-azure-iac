variable "https_traffic" {
  type        = bool
  description = "Storage account https traffic"
  default = true
}

variable "ctre" {
  type        = bool
  description = "Should cross Tenant replication be enabled. Defaults to true."
  default = false
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow or disallow nested items within this Account to opt into being public. Defaults to true"
  default = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to true"
  default = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the public network access is enabled? Defaults to false"
  default = false
}

variable "default_to_oauth_authentication" {
  type        = bool
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false"
  default = false
}

variable "is_hns_enabled" {
  type        = bool
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created."
  default = false
}

variable "nfsv3_enabled" {
  type        = bool
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to false"
  default = false
}

variable "sac_name" {
  description = "Storage account name."
  type        = string
}

variable "sac_rg_name" {
  description = "Resource group where to create storage account."
  type        = string
}

variable "sac_location" {
  description = "Location where to create storage account."
  type        = string
}

variable "location" {
  description = "Location of the storage account."
  type        = string
  default     = "westeurope"

}

variable "account_tier" {
  description = "Storage Account tier."
  type        = string
  default     = "Standard"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid: Hot and Cool, defaults to Hot."
  type        = string
  default     = "Hot"
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created."
  type        = string
}

variable "resource_group_location_pep" {
  description = "Location of resource group where private endpoint should be stored."
  type        = string
}

variable "resource_group_name_pep" {
  description = "Name of resource group where private endpoint should be stored."
  type        = string
}

variable "pe_subnet_id" {
  description = "Specifies subnet ID where private endpoint should be created"
  type        = string
}

variable "tls" {
  description = "The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts."
  type        = string
  default = "TLS1_2"
}

variable "replication_type" {
  description = "Storage Account replication type."
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Defines the Kind of account; Valid: BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2"
  type        = string
  default     = "StorageV2"
}

variable "subresource_names" {
  description = "The ID of the Azure Subnet where the new private Endpoint for the Key vault will be created."
  type    = list(string)
  default = ["blob"]
}

variable "tags" {
  description = "A map of tags to be assigned to the new resource"
  type        = map(string)
  default     = {}
}

variable "tags_pe" {
  description = "A map of tags to be assigned to the new resource"
  type        = map(string)
  default     = {}
}
