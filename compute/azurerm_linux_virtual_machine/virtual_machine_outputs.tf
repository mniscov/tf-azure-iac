output "vm_count" {
  description = "Number of virtual machines"
  value       = var.vm_count
}

output "vm_name" {
  description = "Base name of the virtual machines"
  value       = var.vm_name
}
output "vm_ids" {
  description = "List of VM IDs created"
  value       = azurerm_linux_virtual_machine.vm[*].id
}
