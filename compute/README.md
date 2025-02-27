# Virtual Machine Module Documentation

## Description
This module is used to deploy virtual machines (VMs) on Azure using Terraform. It supports both Linux and Windows VMs, providing a flexible way to provision infrastructure in the cloud.

## Usage
To use this module, add the following code snippet to your Terraform configuration:

### Linux Virtual Machine
```hcl
module "virtual_machine" {
  source = "git::https://github.com/mniscov/tf-azure-iac.git//compute//azurerm_linux_virtual_machine?ref=main"

  vm_count        = "2" #Number of virtual machines to deploy
  rg_name         = "<your-resource-group>" #The resource group should already exist
  keyvault_name   = "<your-key-vault>" #The key vault should already exist
  user			  = "<your-username-for-vms>" #Optional. If you do not set this will use the default admin
  disable_password_authentication = false #Should stay on false if you want to be able to authenticate using password
  vnet            = "de-devopsprod-p-ne-nova-vnet"
  vnet_rg_name    = "<your-vnet-resource-group>" #The resource group should already exist
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
  #IF YOU DON'T NEED KEY VAULT INTEGRATION PLEASE CONSULT BELOW "Don't want to use the module "add_secrets_to_kv"?" SECTION
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
  # If you want to use one password for all VMs you can replace with
  #   kv_secrets = {
  #  "linux-user" = "<YOUR_SINGLE_PASSWORD>"
  #}
  #IMPORTANT..Make sure you have proper rights of your service principal in order to add a secret to he Key Vault
```

### Windows Virtual Machine
```hcl
module "windows_virtual_machine" {
  source = "git::https://github.com/mniscov/tf-azure-iac.git//compute//azurerm_windows_virtual_machine?ref=main"

  vm_count        = "2" # Number of virtual machines to deploy
  rg_name         = "<your-resource-group>" # The resource group should already exist
  keyvault_name   = "<your-key-vault>" # The Key Vault should already exist
  user            = "<your-username-for-vms>" # Optional. If not set, it will use the default admin
  vnet            = "de-devopsprod-p-ne-nova-vnet"
  subnet          = "vms-sn"
  
  location        = "northeurope"
  prefix          = "prefix" # VM prefix used for IP configuration
  vm_name         = "<your-vm-name>"
  dns_servers     = "<dns-servers>" # Optional. If not set, it will use the default on-premise DNS servers

  publisher       = "MicrosoftWindowsServer"
  image_version   = "latest"
  offer           = "WindowsServer"
  sku             = "2019-Datacenter"
  vm_size         = "Standard_D2s_v3"
  storageat       = "Standard_LRS" # The Type of Storage Account backing the OS Disk.

  enable_automatic_updates = true # Windows Update should be enabled

  # Windows-specific options
  timezone = "UTC" # Set the time zone for the VM

  tags = {
    managedBy = "terraform"
    tag = "value"	
  }

  depends_on = [module.add_secrets_to_kv] # IMPORTANT! If you want to add a secret to an existing Key Vault for VMs, use the add_secrets_to_kv module
  #IF YOU DON'T NEED KEY VAULT INTEGRATION PLEASE CONSULT BELOW "Don't want to use the module "add_secrets_to_kv"?" SECTION
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
  # The key is the VM name (e.g., "windows-vm-1"), and the value is a password format (e.g., "mypassword-1").
  # If you want to use one password for all VMs you can replace with
  #   kv_secrets = {
  #  "windows-user" = "<YOUR_SINGLE_PASSWORD>"
  #}
 #IMPORTANT..Make sure you have proper rights of your service principal in order to add a secret to he Key Vault
```

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
resource "azurerm_windows_virtual_machine" "vm" {
...
  admin_username = data.azurerm_key_vault_secret.secret1.name
  admin_password = data.azurerm_key_vault_secret.secret1.value
...
}
```

### Don't want to use the module "add_secrets_to_kv"?
 1. Create another branch
 2. Edit the virtual_machine_main.tf
    - Remove the **data.azurerm_key_vault_secret.secret1.name** and **data.azurerm_key_vault_secret.secret1.value** refferences
```hcl
resource "azurerm_linux_virtual_machine" "vm" {
...
  admin_username        = var.myusername
  admin_password        = var.mypassword
...
}
```
3.  Add the variables to virtual_machine_variables.tf

```hcl
variable "myusername" {
  type        = string
  description = "The user of VM"
}
variable "mypassword" {
  type        = string
  description = "The password of VM"
}
```
4. Give values to the variables when you call the module
- Make sure you modify the branch in the source URL
```hcl
module "virtual_machine" {
  source = "git::https://github.com/mniscov/tf-azure-iac.git//compute//azurerm_linux_virtual_machine?ref=<YOUR-NEWLY-CREATED-BRANCH>"
  myusername = <your-username>
  mypassword = <your-password>
}
- Don't need to use keyvault_name="<your-key-vault>" and depends_on = [module.add_secrets_to_kv] anymore 
```




### Network Configuration
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
### Key Differences Between `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine`

#### 1. Authentication Differences

| Feature                         | Linux (`azurerm_linux_virtual_machine`)                           | Windows (`azurerm_windows_virtual_machine`) |
|---------------------------------|----------------------------------------------------------------|--------------------------------------------|
| **`admin_username` (Required)** |  Yes                                                        |  Yes |
| **`admin_password` (Optional)** |  Only if `disable_password_authentication = false`         |  Required |
| **`admin_ssh_key` (Optional)**  |  Required if `admin_password` is not set (SSH authentication) |  Not available (Windows does not support SSH authentication) |

---

#### 2. OS Customization & User Data

| Feature                         | Linux (`azurerm_linux_virtual_machine`) | Windows (`azurerm_windows_virtual_machine`) |
|---------------------------------|----------------------------------------|--------------------------------------------|
| **Custom Data (`custom_data`)** |  Yes (Used for Cloud-init automation) |  Yes, but **must be Base64-encoded** |
| **Unattended Install (`additional_unattend_content`)** |  No |  Yes (Used for Windows setup automation) |
| **Time Zone Configuration (`timezone`)** |  No |  Yes (Allows setting Windows time zone) |

---

#### 3. OS Patching & Updates

| Feature                         | Linux (`azurerm_linux_virtual_machine`) | Windows (`azurerm_windows_virtual_machine`) |
|---------------------------------|----------------------------------------|--------------------------------------------|
| **Patch Mode (`patch_mode`)** | `AutomaticByPlatform`, `ImageDefault`  | `Manual`, `AutomaticByOS`, `AutomaticByPlatform` |
| **Automatic Updates (`enable_automatic_updates`)** |  No |  Yes (Windows Update) |
| **Hot Patching (`hotpatching_enabled`)** |  No |  Yes (Apply updates without rebooting) |

---

#### 4. Security Features

| Feature                         | Linux (`azurerm_linux_virtual_machine`) | Windows (`azurerm_windows_virtual_machine`) |
|---------------------------------|----------------------------------------|--------------------------------------------|
| **Secure Boot (`secure_boot_enabled`)** |  No |  Yes |
| **Virtual TPM (`vtpm_enabled`)** |  No |  Yes |
| **Disk Encryption (`disk_encryption_set_id`)** |  Yes |  Yes |

---

#### 5. Remote Management

| Feature                         | Linux (`azurerm_linux_virtual_machine`) | Windows (`azurerm_windows_virtual_machine`) |
|---------------------------------|----------------------------------------|--------------------------------------------|
| **SSH Access (`admin_ssh_key`)** |  Yes |  No |
| **WinRM Remote Management (`winrm_listener`)** |  No |  Yes |
| **RDP Access** |  No |  Yes (via Remote Desktop) |



## Notes
- The module provisions VMs with a default OS image; you can customize it based on your needs.
- The admin username and password are retrieved from **Azure Key Vault** secrets instead of being manually set.
- The Key Vault secret must be created beforehand, and its name must be passed using the `user` variable.
- The module references the Key Vault using `data.azurerm_key_vault` and fetches the secret using `data.azurerm_key_vault_secret`.
- The **network interface (NIC)** is dynamically created and linked to the specified subnet.

