data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = upper("${var.resource_prefix}-alert-group")
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = upper(var.short_name)
  enabled             = var.enabled

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  tags = var.tags
}
resource "azurerm_monitor_activity_log_alert" "log_alert" {
  for_each            = var.enable_log_alert == true ? merge(var.log_criteria, var.custom_criteria) : {}
  name                = upper("SEC-ALRT-${data.azurerm_subscription.current.display_name}-001-${each.value.name}")
  scopes              = [data.azurerm_subscription.current.id]
  description         = each.value.description

  criteria {
    category       = each.value.category
    operation_name = each.value.operation_name
    resource_type  = each.value.resource_type
  }

  action {
    action_group_id    = azurerm_monitor_action_group.action_group.id
    webhook_properties = var.webhook_properties
  }

  tags = var.tags
}
