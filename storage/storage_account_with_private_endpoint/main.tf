###Read current client configuration#############
# Use "az login" and # "az account set --subscription <name or id>"
# before executing terraform
#################################################

data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

###Create storage account########################
#################################################

resource "azurerm_storage_account" "storage_account" {
  name                      = "${var.sac_name}sacc" #Required; Storage account name
  resource_group_name       = var.sac_rg_name #Required; Resource group name
  location                  = var.sac_location #Required; Location (westeurope,northeurope)
  account_tier              = var.account_tier #Required; Tier, Standard or Premium; default Standard
  account_replication_type  = var.replication_type #Required; LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS; default LRS
  
  ###### OPTIONAL BLOCK / USE IF YOU REQUIRE IT / IF NOT SPECIFIED DEFAULT VALUES TAKEN ######

  account_kind              = var.account_kind #Optional; Defines the Kind of account; Valid: BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Default StorageV2.
  #Changing the account_kind value from Storage to StorageV2 will not trigger a force new on the storage account, it will only upgrade the existing storage account from Storage to StorageV2 keeping the existing storage account in place.
  access_tier = var.access_tier #Optional; Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid: Hot and Cool, defaults to Hot.
  edge_zone = var.edge_zone #Optional; Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created.
  is_hns_enabled = var.is_hns_enabled #Optional; Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created. Default false.
  #"is_hns_enabled" can only be true when account_tier is Standard or when account_tier is Premium and account_kind is BlockBlobStorage
  nfsv3_enabled = var.nfsv3_enabled # Optional; Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to false.
  #"nfsv3_enabled" can only be true when account_tier is Standard and account_kind is StorageV2, or account_tier is Premium and account_kind is BlockBlobStorage. Additionally, the is_hns_enabled is true and account_replication_type must be LRS or RAGRS.
  tags = var.tags #Optional; Set tags on the storage account / example: environment = "p"
  

  ###### DO NOT CHANGE DEFAULT VALUES / SET FOR OPTIMAL CONFIGURATION WITH PRIVATE ENDPOINT AND HARDENED SECURITY ######
  
  cross_tenant_replication_enabled = var.ctre #Optional; Should cross Tenant replication be enabled. Defaults to false.
  min_tls_version = var.tls #Optional; The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts.
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public #Optional; Allow or disallow nested items within this Account to opt into being public. Defaults to false
  shared_access_key_enabled = var.shared_access_key_enabled #Optional; Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to false
  default_to_oauth_authentication = var.default_to_oauth_authentication #Optional; Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false
  public_network_access_enabled = var.public_network_access_enabled #Optional; Whether the public network access is enabled? Defaults to false
  https_traffic_only_enabled = var.https_traffic #Optional; Forces HTTPS if enabled; true/false; default true
  
}

###Create private endpoint for storage account###
#################################################

resource "azurerm_private_endpoint" "private_endpoint" {
  for_each = toset(var.subresource_names)
  name                = "${split("-", data.azurerm_subscription.current.display_name)[0]}-${var.sac_name}-${each.value}-pep" #Name of the private endpoint to be created
  location            = var.resource_group_location_pep
  resource_group_name = var.resource_group_name_pep
  subnet_id           = var.pe_subnet_id
  tags = var.tags_pe #Optional; Set tags on the storage account / example: environment = "p"
  private_service_connection {
    name                           = "${split("-", data.azurerm_subscription.current.display_name)[0]}-${var.sac_name}-${each.value}-pep"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["${each.value}"] #Subresource names which the Private Endpoint is able to connect to, blob, file; https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
    is_manual_connection           = false #A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection to the remote resource. Set to false
    
  }
 
  #Do not create private DNS zone group, record added by policy initative or manually into shared private DNS zone
  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
 
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
