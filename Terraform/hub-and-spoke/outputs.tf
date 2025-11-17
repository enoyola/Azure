output "hub_resource_group_name" {
  description = "Name of the hub resource group"
  value       = azurerm_resource_group.hub.name
}

output "hub_vnet_id" {
  description = "ID of the hub VNet"
  value       = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet"
  value       = module.hub_network.vnet_name
}

output "spoke_vnet_ids" {
  description = "Map of spoke names to VNet IDs"
  value       = { for k, v in module.spoke_networks : k => v.vnet_id }
}

output "spoke_vnet_names" {
  description = "Map of spoke names to VNet names"
  value       = { for k, v in module.spoke_networks : k => v.vnet_name }
}

output "firewall_private_ip" {
  description = "Private IP address of Azure Firewall"
  value       = var.deploy_firewall ? module.azure_firewall[0].private_ip_address : null
}

output "firewall_public_ip" {
  description = "Public IP address of Azure Firewall"
  value       = var.deploy_firewall ? module.azure_firewall[0].public_ip_address : null
}

output "bastion_dns_name" {
  description = "DNS name of Azure Bastion"
  value       = var.deploy_bastion ? module.bastion[0].dns_name : null
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.deploy_vpn_gateway ? module.vpn_gateway[0].gateway_id : null
}

output "vpn_gateway_public_ip" {
  description = "Public IP of the VPN Gateway"
  value       = var.deploy_vpn_gateway ? module.vpn_gateway[0].public_ip_address : null
}

output "spoke_subnet_ids" {
  description = "Map of spoke names to their subnet IDs"
  value       = { for k, v in module.spoke_networks : k => v.subnet_ids }
}
