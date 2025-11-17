locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Client      = var.client_name
      ManagedBy   = "Terraform"
    }
  )
  
  resource_prefix = "${var.client_name}-${var.environment}"
}

# Resource Group
module "resource_group" {
  source = "./modules/resource-group"
  
  name     = "${local.resource_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# Networking
module "networking" {
  source = "./modules/networking"
  
  resource_group_name = module.resource_group.name
  location            = var.location
  vnet_name           = "${local.resource_prefix}-vnet"
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
  storage_account_name     = lower(replace("${local.resource_prefix}st", "-", ""))
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
  vm_name             = "${local.resource_prefix}-vm"
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
  server_name         = "${local.resource_prefix}-sqlserver"
  database_name       = "${local.resource_prefix}-db"
  database_type       = var.database_type
  admin_username      = var.admin_username
  tags                = local.common_tags
}

# App Service
module "app_service" {
  count  = var.deploy_app_service ? 1 : 0
  source = "./modules/app-service"
  
  resource_group_name  = module.resource_group.name
  location             = var.location
  app_service_plan_name = "${local.resource_prefix}-asp"
  app_service_name     = "${local.resource_prefix}-app"
  sku_name             = var.app_service_sku
  tags                 = local.common_tags
}
