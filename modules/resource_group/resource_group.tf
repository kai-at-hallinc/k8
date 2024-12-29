# this Terrafomr module creates a resource group in Azure. Name is concatenated from variables. 
# Contributor role is assigned for user assigned identity on resource group level.

resource "azurerm_resource_group" "aks-resources" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_role_assignment" "resource_group" {
  scope                = azurerm_resource_group.aks-resources.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.oidc_identity.principal_id
}