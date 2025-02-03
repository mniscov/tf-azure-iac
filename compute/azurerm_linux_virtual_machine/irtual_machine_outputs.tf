output "vm_ids" {
  description = "List of VM IDs"
  value       = azurerm_virtual_machine.this[*].id
}

output "vm_names" {
  description = "List of VM names"
  value       = azurerm_virtual_machine.this[*].name
}

output "vm_tags" {
  description = "List of VM tags"
  value       = azurerm_virtual_machine.this[*].tags
}
