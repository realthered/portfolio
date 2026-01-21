provider "azuread" {}

resource "azuread_application" "terraform" {
  display_name = "${local.app_name}-terraform"
}

resource "azuread_service_principal" "terraform" {
  client_id = azuread_application.terraform.client_id
}

resource "azuread_service_principal_password" "terraform" {
  service_principal_id = azuread_service_principal.terraform.id
}

# Contributor 권한 부여
resource "azurerm_role_assignment" "terraform_contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform.object_id
}
