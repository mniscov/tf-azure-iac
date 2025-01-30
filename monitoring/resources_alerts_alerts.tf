output "action_group_id" {
  value = azurerm_monitor_action_group.action_group.id
}

output "log_alert_name" {
  value = azurerm_monitor_activity_log_alert.log_alert.name
}

output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}
