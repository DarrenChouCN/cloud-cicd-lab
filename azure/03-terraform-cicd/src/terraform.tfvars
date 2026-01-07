environment             = "dev"
resource_group_location = "australiasoutheast"

resource_group_name     = "rg-iac-webapp-dev-ase"
app_service_plan_name   = "asp-iac-webapp-dev-ase"
app_service_name        = "app-iac-webapp-dev-ase"

# keep it short because we append a random suffix; must be lowercase+numbers only
storage_account_name    = "stiacdevwebappase"
