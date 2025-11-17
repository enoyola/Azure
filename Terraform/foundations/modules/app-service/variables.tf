variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "os_type" {
  description = "OS type (Linux or Windows)"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU name for App Service Plan"
  type        = string
  default     = "B1"
}

variable "runtime_stack" {
  description = "Runtime stack (node, python, dotnet, etc.)"
  type        = string
  default     = "node"
}

variable "runtime_version" {
  description = "Runtime version"
  type        = string
  default     = "18-lts"
}

variable "always_on" {
  description = "Should the app be always on"
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "App settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
