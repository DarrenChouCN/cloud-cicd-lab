resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_service_plan" "plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "B1"
  os_type             = "Linux"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  web_app_name = "${var.app_service_name}-${random_string.suffix.result}"

  # Storage account name rules: 3-24 chars, lowercase letters and numbers only
  storage_account_name = "${var.storage_account_name}${random_string.suffix.result}"
}

resource "azurerm_linux_web_app" "app" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    ftps_state = "Disabled"
    application_stack {
      dotnet_version = "6.0"
    }
  }

  app_settings = {
    "ENVIRONMENT" = var.environment
    "SOME_KEY"    = "some-value"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_storage_account" "storage" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = false

  allow_nested_items_to_be_public = false

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
