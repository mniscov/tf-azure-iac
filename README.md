# Terraform Azure Infrastructure as Code (IaC) Repository

## Overview
This repository contains Terraform modules for provisioning and managing **Azure infrastructure** using Infrastructure as Code (IaC). Each module is designed to be reusable, configurable, and scalable, enabling automation and efficient deployment of cloud resources.

## Repository Structure
```
├── compute/                 # Virtual Machines (Linux & Windows)
│   ├── azurerm_linux_virtual_machine/
│   ├── azurerm_windows_virtual_machine/
│   ├── README.md
├── backup/                  # Backup and Recovery Services Vault
│   ├── README.md
├── key_vault/               # Azure Key Vault Management
│   ├── key_vault_with_private_endpoint/
│   ├── README.md
├── monitoring/              # Azure Monitor & Alerts
│   ├── README.md
├── add-secrets-to-kv/       # Storing Secrets in Key Vault
│   ├── README.md
├── README.md                # Repository-level Documentation
```

## Prerequisites
Before using this repository, ensure you have the following:
- **Terraform** (`>= 0.13`)
- **Azure CLI** (`az`)
- **An Azure Subscription**
- **Terraform backend configured** (if using remote state storage)

## Usage
This repository follows a modular approach. To use the modules, reference them in your `main.tf` configuration:

### Example: Deploying a Linux Virtual Machine
```hcl
module "linux_vm" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//compute/azurerm_linux_virtual_machine"
  vm_name       = "example-vm"
  resource_group_name = "example-rg"
  location      = "East US"
  vm_size       = "Standard_D2s_v3"
  keyvault_name = "example-kv"
  user          = "adminuser"
  os_disk_size_gb = 30
}
```

### Example: Creating a Key Vault
```hcl
module "key_vault" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//key_vault/key_vault_with_private_endpoint"
  key_vault_name      = "example-kv"
  resource_group_name = "example-rg"
  location           = "East US"
  sku_name           = "standard"
  enable_private_endpoint = true
}
```

## Modules
### 1. Compute
- Deploys **Azure Virtual Machines (VMs)** for Linux and Windows.
- Uses **Azure Key Vault** for storing VM credentials.
- Supports **custom networking and resource groups**.

### 2. Backup
- Creates an **Azure Recovery Services Vault**.
- Defines **backup policies** for Virtual Machines.
- Ensures automated VM protection.

### 3. Key Vault
- Deploys **Azure Key Vault** with optional **Private Endpoint**.
- Configures **RBAC and access policies**.
- Stores and manages secrets securely.

### 4. Monitoring
- Configures **Azure Monitor** to track performance.
- Creates **metric and log-based alerts**.
- Uses **Action Groups** for notifications.

### 5. Add Secrets to Key Vault
- Enables storing sensitive values in **Azure Key Vault**.
- Supports secret retrieval for other modules.

## Deployment Workflow
1. **Clone the repository**
   ```sh
   git clone https://github.com/mniscov/tf-azure-iac-main.git
   cd tf-azure-iac-main
   ```
2. **Initialize Terraform**
   ```sh
   terraform init
   ```
3. **Plan the Deployment**
   ```sh
   terraform plan
   ```
4. **Apply Changes**
   ```sh
   terraform apply
   ```

## Best Practices
- Use **remote state** with an Azure Storage Account to manage Terraform state securely.
- Configure **backend.tf** for state management.
- Leverage **modules** to keep Terraform configurations modular and maintainable.
- Use **Terraform variables** (`.tfvars`) for better configuration management.

## Contributions
Feel free to submit **pull requests** for improvements. Ensure that new modules follow the existing **modular structure** and best practices.

## License
This project is licensed under the **MIT License**.

---
For further details, check each module’s **README.md** file.

