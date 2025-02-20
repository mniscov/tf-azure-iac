# Backup Module Documentation

## Description
This module is used to configure backup resources in Azure using Terraform. It provisions an **Azure Recovery Services Vault**, sets up a **backup policy**, and associates virtual machines with the backup policy.

## Usage
To use this module, add the following code snippet to your Terraform configuration:

```hcl
module "backup" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//backup"

  # Required Variables
  resource_group_name = "example-rg"
  resource_prefix     = "example"
  location           = "East US"
  vault_sku          = "Standard"
  public_network_access_enabled = false
  storage_mode_type  = "GeoRedundant"
  backup_frequency   = "Daily"
  backup_time        = "23:00"
  retention_daily_count = 7
  vm_names           = ["vm1", "vm2"]
}
```

## Variables
| Name                          | Type   | Description                                           | Default |
|--------------------------------|--------|-------------------------------------------------------|---------|
| `resource_group_name`         | string | The name of the existing resource group.             | N/A     |
| `resource_prefix`             | string | A prefix for naming resources.                       | N/A     |
| `location`                    | string | The Azure region where resources will be deployed.   | N/A     |
| `vault_sku`                   | string | The SKU of the Recovery Services Vault.              | "Standard" |
| `public_network_access_enabled` | bool  | Whether public network access is enabled.            | false   |
| `storage_mode_type`           | string | Storage mode type (e.g., "GeoRedundant").            | "GeoRedundant" |
| `backup_frequency`            | string | Backup frequency (e.g., "Daily").                    | "Daily" |
| `backup_time`                 | string | Time of day for backups (UTC format).                | "23:00" |
| `retention_daily_count`       | number | Number of daily backup retention copies.             | 7       |
| `vm_names`                    | list   | List of VM names to be backed up.                    | []      |

## Outputs
| Name                  | Description |
|-----------------------|-------------|
| `recovery_vault_id`  | The ID of the Recovery Services Vault. |
| `backup_policy_id`   | The ID of the backup policy. |

## Dependencies
- This module requires a pre-existing **resource group**.
- Virtual machines to be backed up **must already exist**.
- Ensure that the appropriate **Azure credentials** are configured for Terraform.

## Backup Configuration
This module creates an **Azure Recovery Services Vault**, defines a backup policy, and associates it with existing virtual machines.

### Referencing an Existing Resource Group
```hcl
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
```

### Creating a Recovery Services Vault
```hcl
resource "azurerm_recovery_services_vault" "bk-vault" {
  name                = "${var.resource_prefix}-vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.vault_sku
  public_network_access_enabled = var.public_network_access_enabled
  storage_mode_type   = var.storage_mode_type
  tags = var.tags
}
```

### Defining a Backup Policy
```hcl
resource "azurerm_backup_policy_vm" "daily-policy" {
  name                = "${var.resource_prefix}-vault-policy"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.bk-vault.name

  backup {
    frequency = var.backup_frequency
    time      = var.backup_time
  }
  retention_daily {
    count = var.retention_daily_count
  }
}
```

### Associating Virtual Machines to the Backup Policy
```hcl
data "azurerm_virtual_machine" "vms" {
  for_each            = toset(var.vm_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  for_each = data.azurerm_virtual_machine.vms

  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.bk-vault.name
  source_vm_id        = each.value.id
  backup_policy_id    = azurerm_backup_policy_vm.daily-policy.id
}
```

## Notes
- The Recovery Services Vault is provisioned with a specific **storage mode type**.
- The **backup policy** is applied to existing VMs, which are referenced dynamically.
- Ensure that the VM names provided match the actual VM resources in the resource group.
- Backups are scheduled at a specific **UTC time**, which should be adjusted based on business needs.


