# Compute Module Documentation

## Description
This module is used to deploy virtual machines (VMs) on Azure using Terraform. It supports both Linux and Windows VMs, providing a flexible way to provision infrastructure in the cloud.

## Usage
To use this module, add the following code snippet to your Terraform configuration:

### Linux Virtual Machine
```hcl
module "virtual_machine" {
  source = "git::https://github.com/mniscov/tf-azure-iac.git//compute//azurerm_linux_virtual_machine?ref=main"

  vm_count        = "2" #Number of virtual machines to deploy
  rg_name         = "<your-resource-group>" The resource group should already exist
  keyvault_name   = "<your-key-vault>" #The key vault should already exist
  user			  = "<your-username-for-vms>" #Optional. If you do not set this will use the default admin
  disable_password_authentication = false #Should stay on false 
  vnet            = "de-devopsprod-p-ne-nova-vnet"
  subnet          = "vms-sn"
  
  location        = "northeurope"
  prefix          = "prefix" #VM prefix  to be used for IP configuration
  vm_name         = "<your-vm-name>"
  dns_servers     = "<dns-servers>" #Optional. If you do not set this will use the default on-premise dns servers

  publisher       = "Canonical"
  image_version  = "latest"
  offer           = "UbuntuServer"
  sku             = "18.04-LTS"
  vm_size         = "Standard_B2s"
  storageat       = "Standard_LRS" #The Type of Storage Account which should back this the Internal OS Disk.
  tags = {
    managedBy = "terraform"
    tag = "value"	
  }
  depends_on = [module.add_secrets_to_kv] #IMPORTANT! If you want to add a secret to an existing keyvault to be used by vms you should use add_secrets_to_kv module as well
}
```

```hcl
module "add_secrets_to_kv" {
  source            = "git::https://github.com/mniscov/tf-azure-iac.git//add-secrets-to-kv?ref=main"
  keyvault_name     = "<existing-key-vault>" 
  keyvault_rg_name  = "<existing-key-vault-rg>"
  
  kv_secrets = {
    for i in range(var.vm_count) : "${var.vm_name}-${i + 1}" => "<YOUR_PASS_HERE>-${i + 1}"
  }
}
  # Generates a map of secrets for each VM, where the key is the VM name 
  # and the value is a dynamically generated password.
  # These secrets are stored in Azure Key Vault.
  # The key is the VM name (e.g., "linux-vm-1"), and the value is a password format (e.g., "mypassword-1").
```

### Windows Virtual Machine
```hcl
module "windows_virtual_machine" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//compute/azurerm_windows_virtual_machine"

  # Required Variables
  vm_name       = "example-win-vm"
  resource_group_name = "example-rg"
  location      = "East US"
  vm_size       = "Standard_D2s_v3"
  keyvault_name = "example-kv"
  user          = "adminuser"
  os_disk_size_gb = 50
}
```

## Variables
| Name                 | Type   | Description                          | Default |
|----------------------|--------|--------------------------------------|---------|
| `vm_name`           | string | The name of the virtual machine.     | N/A     |
| `resource_group_name` | string | The name of the resource group.     | N/A     |
| `location`          | string | The Azure region to deploy into.    | N/A     |
| `vm_size`           | string | The size of the virtual machine.     | N/A     |
| `keyvault_name`     | string | The name of the Azure Key Vault.     | N/A     |
| `user`              | string | The secret name storing the admin username and password. | N/A     |
| `os_disk_size_gb`   | number | The size of the OS disk in GB.       | N/A     |
| `subnet`            | string | The name of the subnet.              | N/A     |
| `vnet`              | string | The name of the virtual network.     | N/A     |
| `vm_count`          | number | The number of VMs to create.         | 1       |
| `dns_servers`       | list   | Optional list of DNS servers.        | []      |
| `tags`              | map    | A map of tags to apply to resources. | {}      |

## Outputs
| Name                | Description |
|---------------------|-------------|
| `vm_id`            | The ID of the created VM. |
| `vm_public_ip`     | The public IP address of the VM. |
| `vm_private_ip`    | The private IP address of the VM. |

## Dependencies
- This module requires a pre-existing **resource group**.
- This module requires a pre-existing **Azure Key Vault** containing a secret for the VM's admin credentials.
- The **virtual network (VNet)** and **subnet** must already exist.
- Ensure that the appropriate **Azure credentials** are configured for Terraform.

## Key Vault Integration
Both Linux and Windows virtual machines retrieve their administrator credentials from an **Azure Key Vault** secret. Below is how Terraform references the secret:

### Referencing Azure Key Vault
```hcl
data "azurerm_key_vault" "secretkv" {
  name                = var.keyvault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
```

### Fetching the Secret from Key Vault
```hcl
data "azurerm_key_vault_secret" "secret1" {
  name         = var.user
  key_vault_id = data.azurerm_key_vault.secretkv.id
}
```

### Using the Secret in Virtual Machine Deployment
```hcl
admin_username = data.azurerm_key_vault_secret.secret1.name
admin_password = data.azurerm_key_vault_secret.secret1.value
```

## Network Configuration
Each VM is deployed in a specific subnet of a Virtual Network. Ensure that the subnet and VNet exist before using the module:

### Referencing a Subnet
```hcl
data "azurerm_subnet" "vnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.rg_name
}
```

### Creating a Network Interface
```hcl
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.vm_name}-${count.index + 1}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_servers         = var.dns_servers

  ip_configuration {
    name                          = "${var.prefix}-${count.index + 1}-nic"
    subnet_id                     = data.azurerm_subnet.vnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

## Notes
- The module provisions VMs with a default OS image; you can customize it based on your needs.
- The admin username and password are retrieved from **Azure Key Vault** secrets instead of being manually set.
- The Key Vault secret must be created beforehand, and its name must be passed using the `user` variable.
- The module references the Key Vault using `data.azurerm_key_vault` and fetches the secret using `data.azurerm_key_vault_secret`.
- The **network interface (NIC)** is dynamically created and linked to the specified subnet.

