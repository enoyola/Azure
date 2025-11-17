variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
}

variable "sku_tier" {
  description = "SKU tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "subnet_id" {
  description = "ID of the AzureFirewallSubnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
