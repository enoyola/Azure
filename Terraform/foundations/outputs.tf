output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = module.resource_group.location
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.networking.subnet_ids
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = var.deploy_storage ? module.storage[0].storage_account_name : null
}

output "storage_primary_connection_string" {
  description = "Primary connection string for storage account"
  value       = var.deploy_storage ? module.storage[0].primary_connection_string : null
  sensitive   = true
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = var.deploy_vm ? module.virtual_machine[0].vm_id : null
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = var.deploy_vm ? module.virtual_machine[0].private_ip_address : null
}

output "database_server_fqdn" {
  description = "FQDN of the database server"
  value       = var.deploy_database ? module.database[0].server_fqdn : null
}

output "database_name" {
  description = "Name of the database"
  value       = var.deploy_database ? module.database[0].database_name : null
}

output "app_service_default_hostname" {
  description = "Default hostname of the app service"
  value       = var.deploy_app_service ? module.app_service[0].default_hostname : null
}
