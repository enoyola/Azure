variable "client_name" {
  description = "Client name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Networking variables
variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet address prefixes"
  type        = map(string)
  default = {
    web     = "10.0.1.0/24"
    app     = "10.0.2.0/24"
    data    = "10.0.3.0/24"
    gateway = "10.0.4.0/24"
  }
}

# VM variables
variable "deploy_vm" {
  description = "Whether to deploy virtual machines"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

# Storage variables
variable "deploy_storage" {
  description = "Whether to deploy storage account"
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

# Database variables
variable "deploy_database" {
  description = "Whether to deploy database"
  type        = bool
  default     = false
}

variable "database_type" {
  description = "Type of database (sql, mysql, postgresql)"
  type        = string
  default     = "sql"
}

# App Service variables
variable "deploy_app_service" {
  description = "Whether to deploy app service"
  type        = bool
  default     = false
}

variable "app_service_sku" {
  description = "App Service plan SKU"
  type        = string
  default     = "B1"
}
