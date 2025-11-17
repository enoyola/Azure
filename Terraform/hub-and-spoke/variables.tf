variable "client_name" {
  description = "Client name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Hub Network Configuration
variable "hub_vnet_address_space" {
  description = "Address space for hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnets" {
  description = "Hub subnet configuration"
  type = map(object({
    address_prefix = string
    nsg_required   = bool
  }))
  default = {
    AzureFirewallSubnet = {
      address_prefix = "10.0.1.0/26"
      nsg_required   = false
    }
    AzureBastionSubnet = {
      address_prefix = "10.0.2.0/26"
      nsg_required   = true
    }
    GatewaySubnet = {
      address_prefix = "10.0.3.0/27"
      nsg_required   = false
    }
    SharedServices = {
      address_prefix = "10.0.4.0/24"
      nsg_required   = true
    }
  }
}

# Spoke Networks Configuration
variable "spoke_vnets" {
  description = "Spoke VNet configurations"
  type = map(object({
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
    }))
  }))
  default = {
    production = {
      address_space = ["10.1.0.0/16"]
      subnets = {
        web  = { address_prefix = "10.1.1.0/24" }
        app  = { address_prefix = "10.1.2.0/24" }
        data = { address_prefix = "10.1.3.0/24" }
      }
    }
    development = {
      address_space = ["10.2.0.0/16"]
      subnets = {
        web  = { address_prefix = "10.2.1.0/24" }
        app  = { address_prefix = "10.2.2.0/24" }
        data = { address_prefix = "10.2.3.0/24" }
      }
    }
    shared = {
      address_space = ["10.3.0.0/16"]
      subnets = {
        monitoring = { address_prefix = "10.3.1.0/24" }
        backup     = { address_prefix = "10.3.2.0/24" }
      }
    }
  }
}

# Azure Firewall Configuration
variable "deploy_firewall" {
  description = "Whether to deploy Azure Firewall"
  type        = bool
  default     = true
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier"
  type        = string
  default     = "Standard"
}

# Azure Bastion Configuration
variable "deploy_bastion" {
  description = "Whether to deploy Azure Bastion"
  type        = bool
  default     = true
}

variable "bastion_sku" {
  description = "Azure Bastion SKU"
  type        = string
  default     = "Basic"
}

# VPN Gateway Configuration
variable "deploy_vpn_gateway" {
  description = "Whether to deploy VPN Gateway"
  type        = bool
  default     = false
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU"
  type        = string
  default     = "VpnGw1"
}

variable "vpn_type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}

# Peering Configuration
variable "allow_gateway_transit" {
  description = "Allow gateway transit from hub to spokes"
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Allow spokes to use hub gateway"
  type        = bool
  default     = true
}
