# Virtual Machine Scale Set Module Documentation

## Description
This module provisions an **Azure Virtual Machine Scale Set** with configurable security settings.

## Usage
To use this module, add the following code snippet to your Terraform configuration by replace the values below with your needed values:

```hcl
module "vmss" {
  source = "git::https://github.com/mniscov/tf-azure-iac.git//vmss/azurerm_windows_vmss?ref=main"

  vnet_name = data.azurerm_virtual_network.existing_vnet.name
  subnet_name = data.azurerm_subnet.existing_subnet.name
  # VMSS Specific
  vmss_name                = "windows-build-agent-vmss"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  vmss_sku            = "Standard_DS1_v2"
  vmss_instances           = 0
  admin_username      = "adminuser"
  admin_password      = "adminpassword123!"
  computer_name_prefix = "vm-"

  # Source Image refference
  image_publisher    = "MicrosoftWindowsServer"
  image_offer        = "WindowsServer"
  image_sku          = "2019-Datacenter"
  image_version      = "latest"

  # Storage Configuration
  os_disk_storage_account_type = "Standard_LRS"
  os_disk_caching             = "ReadWrite"
  os_disk_size_gb         = 200 
    
  # Network Interface
  network_interface_name    = "build-agent-nic"
  ip_configuration_name      = "internal"
  
  # Tags
  tags = {
    ManagedBy = "Terraform"
    Usage = "Build Agent"
    ContactPerson = "m.niscov@externals.pheonixgroup.eu"
  }
}
```
