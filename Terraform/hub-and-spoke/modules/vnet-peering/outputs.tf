output "peering_id" {
  description = "ID of the VNet peering"
  value       = azurerm_virtual_network_peering.peering.id
}

output "peering_name" {
  description = "Name of the VNet peering"
  value       = azurerm_virtual_network_peering.peering.name
}
