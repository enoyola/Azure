resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on = var.always_on

    application_stack {
      node_version = var.runtime_stack == "node" ? var.runtime_version : null
      python_version = var.runtime_stack == "python" ? var.runtime_version : null
      dotnet_version = var.runtime_stack == "dotnet" ? var.runtime_version : null
    }
  }

  app_settings = var.app_settings

  tags = var.tags
}

resource "azurerm_windows_web_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on = var.always_on

    application_stack {
      current_stack  = var.runtime_stack
      node_version   = var.runtime_stack == "node" ? var.runtime_version : null
      python_version = var.runtime_stack == "python" ? var.runtime_version : null
      dotnet_version = var.runtime_stack == "dotnet" ? var.runtime_version : null
    }
  }

  app_settings = var.app_settings

  tags = var.tags
}
