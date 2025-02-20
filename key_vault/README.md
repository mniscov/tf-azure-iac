# Key Vault Module Documentation

## Description
This module provisions an **Azure Key Vault** with configurable security settings, including **RBAC authorization**, **network ACLs**, and an optional **Private Endpoint**. It also supports **role assignments** for fine-grained access control.

## Usage
To use this module, add the following code snippet to your Terraform configuration:

```hcl
module "key_vault" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//key_vault/key_vault_with_private_endpoint"

  # Required Variables
  kv_config = {
    name                        = "example-kv"
    location                    = "East US"
    resource_group_name         = "example-rg"
    sku_name                    = "standard"
    soft_delete_retention_days  = 90
  }
  enable_rbac_authorization = true
  enabled_for_disk_encryption = true
  purge_protection_enabled = false
  public_network_access = false
  kv_default_action = "Deny"
  kv_allowed_cidr = ["10.0.0.0/16"]
  pe_name = "example-kv-pe"
  pe_subnet_id = "subnet-id"
  role_assignments = {
    "Reader"  = ["user-object-id"]
    "Owner"   = ["admin-object-id"]
  }
}
```

## Variables
| Name                          | Type   | Description                                           | Default |
|--------------------------------|--------|-------------------------------------------------------|---------|
| `kv_config`                   | object | Configuration object for Key Vault parameters.        | N/A     |
| `enable_rbac_authorization`   | bool   | Enable RBAC authorization for Key Vault.             | false   |
| `enabled_for_disk_encryption` | bool   | Allow VM disk encryption.                            | false   |
| `purge_protection_enabled`    | bool   | Enable purge protection for soft-deleted secrets.    | false   |
| `public_network_access`       | bool   | Enable public network access.                        | false   |
| `kv_default_action`           | string | Default network access policy (Allow/Deny).          | "Deny"  |
| `kv_allowed_cidr`             | list   | List of allowed IP CIDRs for Key Vault access.       | []      |
| `pe_name`                     | string | Name of the private endpoint (optional).             | ""      |
| `pe_subnet_id`                | string | Subnet ID for the private endpoint.                  | ""      |
| `role_assignments`            | map    | Mapping of roles to principal IDs.                   | {}      |

## Outputs
| Name                  | Description |
|-----------------------|-------------|
| `key_vault_id`       | The ID of the created Key Vault. |
| `private_endpoint_id` | The ID of the private endpoint (if enabled). |

## Dependencies
- This module requires a pre-existing **resource group**.
- If `pe_name` is specified, a **Private Endpoint** will be created in the provided **subnet**.
- Ensure that the appropriate **Azure credentials** are configured for Terraform.

## Key Vault Configuration
This module provisions an **Azure Key Vault** with network ACLs and role-based access control.

### Terraform Provider Configuration
```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = var.purgedelete
      recover_soft_deleted_key_vaults = var.recover
    }
  }
}
```

### Creating an Azure Key Vault
```hcl
resource "azurerm_key_vault" "key_vault" {
  name                        = var.kv_config.name
  location                    = var.kv_config.location
  resource_group_name         = var.kv_config.resource_group_name
  sku_name                    = var.kv_config.sku_name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = var.public_network_access
  soft_delete_retention_days   = var.kv_config.soft_delete_retention_days
  purge_protection_enabled     = var.purge_protection_enabled
  enable_rbac_authorization    = var.enable_rbac_authorization
  tags                        = var.tags

  network_acls {
    default_action = var.kv_default_action
    bypass         = "AzureServices"
    ip_rules       = var.kv_allowed_cidr
  }
}
```

### Configuring Private Endpoint
```hcl
resource "azurerm_private_endpoint" "pe" {
  count               = var.pe_name == "" ? 0 : 1
  name                = var.pe_name
  location            = var.kv_config.location
  resource_group_name = var.kv_config.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.kv_config.name}-pep"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
  }
}
```

### Assigning Roles to Users
```hcl
locals {
  principal_roles_list = flatten([
    for role, principals in var.role_assignments : [
      for principal in principals : {
        role      = role
        principal = principal
      }
    ]
  ])

  principal_roles_tuple = {
    for obj in local.principal_roles_list : "${obj.role}_${obj.principal}" => obj
  }

  principal_roles_map = tomap(local.principal_roles_tuple)
}

resource "azurerm_role_assignment" "role_assignments" {
  for_each             = local.principal_roles_map
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal
  depends_on = [azurerm_key_vault.key_vault]
}
```

## Notes
- If **Private Endpoint** is enabled, ensure that a **Private DNS Zone** is configured.
- **RBAC authorization** can be enabled for more granular access control.
- The module creates a Key Vault with a **configurable SKU**, allowing for standard or premium features.
- **Role assignments** can be dynamically managed via the `role_assignments` variable.

