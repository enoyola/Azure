locals {
  client_token      = lower(replace(replace(var.client_name, " ", "-"), "_", "-"))
  environment_token = lower(replace(replace(var.environment, " ", "-"), "_", "-"))
  location_token    = lower(replace(replace(var.location, " ", ""), "_", ""))
  storage_token     = lower(replace(replace(var.client_name, " ", ""), "_", ""))

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Client      = var.client_name
      ManagedBy   = "Terraform"
    }
  )

  sql_server_name        = "sql-${local.client_token}-${local.environment_token}-${local.location_token}"
  mysql_server_name      = "mysql-${local.client_token}-${local.environment_token}-${local.location_token}"
  postgresql_server_name = "psql-${local.client_token}-${local.environment_token}-${local.location_token}"
}

# Resource Group
module "resource_group" {
  source = "./modules/resource-group"

  name     = "rg-${local.client_token}-${local.environment_token}"
  location = var.location
  tags     = local.common_tags
}

# Networking
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  network_name        = local.client_token
  location            = var.location
  vnet_name           = "vnet-${local.client_token}-${local.environment_token}-${local.location_token}-001"
  address_space       = var.vnet_address_space
  subnet_prefixes     = var.subnet_prefixes
  tags                = local.common_tags
}

# Storage Account
module "storage" {
  count  = var.deploy_storage ? 1 : 0
  source = "./modules/storage"

  resource_group_name      = module.resource_group.name
  location                 = var.location
  storage_account_name     = substr("st${local.storage_token}${local.environment_token}${local.location_token}001", 0, 24)
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags
}

# Virtual Machine
module "virtual_machine" {
  count  = var.deploy_vm ? 1 : 0
  source = "./modules/virtual-machine"

  resource_group_name = module.resource_group.name
  location            = var.location
  vm_name             = "vm-${local.client_token}-${local.environment_token}-001"
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  subnet_id           = module.networking.subnet_ids["app"]
  tags                = local.common_tags
}

# Database
module "database" {
  count  = var.deploy_database ? 1 : 0
  source = "./modules/database"

  resource_group_name = module.resource_group.name
  location            = var.location
  server_name         = var.database_type == "sql" ? local.sql_server_name : (var.database_type == "mysql" ? local.mysql_server_name : local.postgresql_server_name)
  database_name       = var.database_type == "sql" ? "sqldb-${local.client_token}-${local.environment_token}" : (var.database_type == "mysql" ? "mysql-db-${local.client_token}-${local.environment_token}" : "psql-db-${local.client_token}-${local.environment_token}")
  database_type       = var.database_type
  admin_username      = var.admin_username
  tags                = local.common_tags
}

# App Service
module "app_service" {
  count  = var.deploy_app_service ? 1 : 0
  source = "./modules/app-service"

  resource_group_name   = module.resource_group.name
  location              = var.location
  app_service_plan_name = "asp-${local.client_token}-${local.environment_token}"
  app_service_name      = "app-${local.client_token}-${local.environment_token}-${local.location_token}-001"
  sku_name              = var.app_service_sku
  tags                  = local.common_tags
}
