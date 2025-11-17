variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "spoke_name" {
  description = "Name identifier for the spoke"
  type        = string
}

variable "vnet_name" {
  description = "Name of the spoke VNet"
  type        = string
}

variable "address_space" {
  description = "Address space for the spoke VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefix = string
  }))
}

variable "hub_address_space" {
  description = "Hub VNet address space for NSG rules"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
