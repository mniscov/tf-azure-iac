# Monitoring Module Documentation

## Description
This module configures **Azure Monitor** to track resource performance and configure alerts for various infrastructure components. It supports **Metric Alerts**, **Log Alerts**, and **Action Groups** for proactive monitoring.

## Usage
To use this module, add the following code snippet to your Terraform configuration:

```hcl
module "monitoring" {
  source = "git::https://github.com/mniscov/tf-azure-iac-main.git//monitoring"

  # Required Variables
  resource_group_name = "example-rg"
  resource_prefix     = "example"
  short_name          = "EXAG"
  enabled             = true
  email_receivers = [
    {
      name          = "Admin Alert"
      email_address = "admin@example.com"
    }
  ]
  enable_log_alert = true
  log_criteria = {
    unauthorized_access = {
      name           = "Unauthorized Access"
      description    = "Triggered when unauthorized access occurs."
      category      = "Administrative"
      operation_name = "Microsoft.Authorization/roleAssignments/write"
      resource_type  = "Microsoft.Resources/subscriptions"
    }
  }
  custom_criteria = {}
  webhook_properties = {}
}
```

## Variables
| Name                  | Type   | Description                                    | Default |
|-----------------------|--------|------------------------------------------------|---------|
| `resource_group_name` | string | The name of the resource group.               | N/A     |
| `resource_prefix`     | string | Prefix used for naming resources.             | N/A     |
| `short_name`          | string | Short name for action group alerts.           | N/A     |
| `enabled`             | bool   | Enable or disable action group.               | true    |
| `email_receivers`     | list   | List of email recipients for alerts.          | []      |
| `enable_log_alert`    | bool   | Enable log-based alerts.                      | false   |
| `log_criteria`        | map    | Log alert criteria configuration.             | {}      |
| `custom_criteria`     | map    | Custom log criteria for alerts.               | {}      |
| `webhook_properties`  | map    | Additional webhook properties.                 | {}      |

## Outputs
| Name              | Description |
|------------------|-------------|
| `alert_rule_ids` | The IDs of the created alert rules. |

## Dependencies
- This module requires a pre-existing **resource group**.
- Ensure that the appropriate **Azure credentials** are configured for Terraform.
- **Action Groups** should be created beforehand to be used in alerts.

## Monitoring Configuration
This module sets up metric-based alerts and log alerts to monitor critical infrastructure events.

### Creating an Action Group
```hcl
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
```

### Creating a Log Alert
```hcl
resource "azurerm_monitor_activity_log_alert" "log_alert" {
  for_each            = var.enable_log_alert == true ? merge(var.log_criteria, var.custom_criteria) : {}
  name                = upper("SEC-ALRT-${data.azurerm_subscription.current.display_name}-001-${each.value.name}")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
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
```

## Notes
- **Log alerts** can be used to monitor unauthorized access and other administrative actions.
- **Email receivers** should be properly configured to receive alerts.
- **Thresholds and alert conditions** should be tailored to the environment to avoid excessive notifications.
- The module supports **custom log criteria** for additional flexibility.

