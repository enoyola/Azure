variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "bastion_name" {
  description = "Name of the Azure Bastion"
  type        = string
}

variable "sku" {
  description = "SKU of Azure Bastion (Basic or Standard)"
  type        = string
  default     = "Basic"
}

variable "subnet_id" {
  description = "ID of the AzureBastionSubnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
