variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "resource_prefix" {
  description = "A prefix to be used for naming resources (e.g., 'myapp')"
  type        = string
}

variable "short_name" {
  description = "Short name for the action group"
  type        = string
}

variable "enabled" {
  description = "Whether the action group is enabled"
  type        = bool
  default = true
}

variable "email_receivers" {
  description = "Email receivers for the action group"
  type = list(object({
    name          = string
    email_address = string
  }))
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

variable "log_criteria" {
  description = "Criteria for the activity log alert"
  type = map(object({
    name           = string
    category       = string
    operation_name = string
    resource_type  = string
    description    = string
  }))
}

variable "custom_criteria" {
  description = "Additional custom criteria for the activity log alert"
  type = map(object({
    category       = string
    operation_name = string
    resource_type  = string
    description    = string
  }))
}

variable "webhook_properties" {
  description = "Webhook properties for the action"
  type        = map(string)
}

variable "enable_log_alert" {
  description = "Whether to enable the activity log alert"
  type        = bool
}
