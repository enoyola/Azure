variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "gateway_name" {
  description = "Name of the VPN Gateway"
  type        = string
}

variable "sku" {
  description = "SKU of the VPN Gateway"
  type        = string
  default     = "VpnGw1"
}

variable "vpn_type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}

variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "ID of the GatewaySubnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
