terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
      version = "2.2.0"
    }
  }
}

resource "azapi_resource" "storage_account" {
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  name      = var.storage_account_name
  location  = var.location
  parent_id = var.resource_group_id

  tags = var.tags

  body = {
    properties = {
      networkAcls = {
        bypass        = "AzureServices"
        defaultAction = "Deny"
        ipRules       = []
      }

      isHnsEnabled                 = false
      minimumTlsVersion            = "TLS1_2"
      publicNetworkAccess          = "Disabled"
      allowBlobPublicAccess        = false
      allowSharedKeyAccess         = true
      defaultToOAuthAuthentication = false
      allowCrossTenantReplication  = false

      encryption = {
        services = {
          blob = { enabled = true }
          file = { enabled = true }
        }
        keySource = "Microsoft.Storage"
      }

      largeFileSharesState     = "Disabled"
      supportsHttpsTrafficOnly = true
      accessTier               = "Cold"
    }
    sku = {
      name = var.storage_account_sku
    }
    kind = var.storage_account_kind
  }
}

resource "azapi_update_resource" "blob_service" {
  type      = "Microsoft.Storage/storageAccounts/blobServices@2022-09-01"
  name      = "default"
  parent_id = azapi_resource.storage_account.id

  body = {
    properties = {
      isVersioningEnabled = true
    }
  }

  depends_on = [azapi_resource.storage_account]
}

resource "azapi_resource" "storage_account_pep" {
  type      = "Microsoft.Network/privateEndpoints@2023-05-01"
  name      = var.private_endpoint_name
  location  = var.location
  parent_id = var.resource_group_id

  tags = var.tags

  body = {
    properties = {
      subnet = {
        id = var.private_endpoint_subnet_id
      }
      privateLinkServiceConnections = [
        {
          name = "blob-connection"
          properties = {
            privateLinkServiceId = azapi_resource.storage_account.id
            groupIds             = ["blob"]
          }
        }
      ]
    }
  }

  depends_on = [azapi_resource.storage_account]
}
