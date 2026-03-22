locals {
  client_token      = lower(replace(replace(var.client_name, " ", "-"), "_", "-"))
  environment_token = lower(replace(replace(var.environment, " ", "-"), "_", "-"))
  location_token    = lower(replace(replace(var.location, " ", ""), "_", ""))
  hub_name_token    = "${local.client_token}-hub"

  common_tags = merge(
    var.tags,
    {
      Environment  = var.environment
      Client       = var.client_name
      ManagedBy    = "Terraform"
      Architecture = "Hub-and-Spoke"
    }
  )
}

# Resource Group
resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.hub_name_token}-${local.environment_token}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "spokes" {
  for_each = var.spoke_vnets

  name     = "rg-${local.client_token}-${lower(replace(replace(each.key, " ", "-"), "_", "-"))}-${local.environment_token}"
  location = var.location
  tags     = local.common_tags
}

# Hub Network
module "hub_network" {
  source = "./modules/hub-network"

  resource_group_name = azurerm_resource_group.hub.name
  network_name        = local.hub_name_token
  location            = var.location
  vnet_name           = "vnet-${local.hub_name_token}-${local.environment_token}-${local.location_token}-001"
  address_space       = var.hub_vnet_address_space
  subnets             = var.hub_subnets
  tags                = local.common_tags
}

# Spoke Networks
module "spoke_networks" {
  for_each = var.spoke_vnets
  source   = "./modules/spoke-network"

  resource_group_name = azurerm_resource_group.spokes[each.key].name
  location            = var.location
  spoke_name          = "${local.client_token}-${lower(replace(replace(each.key, " ", "-"), "_", "-"))}"
  vnet_name           = "vnet-${local.client_token}-${lower(replace(replace(each.key, " ", "-"), "_", "-"))}-${local.environment_token}-${local.location_token}-001"
  address_space       = each.value.address_space
  subnets             = each.value.subnets
  tags                = local.common_tags
}

# VNet Peering - Hub to Spokes
module "hub_to_spoke_peering" {
  for_each = var.spoke_vnets
  source   = "./modules/vnet-peering"

  peering_name                 = "peer-${local.hub_name_token}-to-${lower(replace(replace(each.key, " ", "-"), "_", "-"))}"
  resource_group_name          = azurerm_resource_group.hub.name
  vnet_name                    = module.hub_network.vnet_name
  remote_vnet_id               = module.spoke_networks[each.key].vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.allow_gateway_transit && var.deploy_vpn_gateway
  use_remote_gateways          = false

  depends_on = [module.vpn_gateway]
}

# VNet Peering - Spokes to Hub
module "spoke_to_hub_peering" {
  for_each = var.spoke_vnets
  source   = "./modules/vnet-peering"

  peering_name                 = "peer-${local.client_token}-${lower(replace(replace(each.key, " ", "-"), "_", "-"))}-to-hub"
  resource_group_name          = azurerm_resource_group.spokes[each.key].name
  vnet_name                    = module.spoke_networks[each.key].vnet_name
  remote_vnet_id               = module.hub_network.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways && var.deploy_vpn_gateway

  depends_on = [module.vpn_gateway]
}

# Azure Firewall
module "azure_firewall" {
  count  = var.deploy_firewall ? 1 : 0
  source = "./modules/azure-firewall"

  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  firewall_name       = "afw-${local.hub_name_token}-${local.environment_token}"
  sku_tier            = var.firewall_sku_tier
  subnet_id           = module.hub_network.subnet_ids["AzureFirewallSubnet"]
  tags                = local.common_tags
}

# Azure Bastion
module "bastion" {
  count  = var.deploy_bastion ? 1 : 0
  source = "./modules/bastion"

  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  bastion_name        = "bas-${local.hub_name_token}-${local.environment_token}"
  sku                 = var.bastion_sku
  subnet_id           = module.hub_network.subnet_ids["AzureBastionSubnet"]
  tags                = local.common_tags
}

# VPN Gateway
module "vpn_gateway" {
  count  = var.deploy_vpn_gateway ? 1 : 0
  source = "./modules/vpn-gateway"

  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  gateway_name        = "vpng-${local.hub_name_token}-${local.environment_token}"
  sku                 = var.vpn_gateway_sku
  vpn_type            = var.vpn_type
  subnet_id           = module.hub_network.subnet_ids["GatewaySubnet"]
  tags                = local.common_tags
}
