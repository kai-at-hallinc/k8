# this terraform module defines the user managed identity used in github oidc authentication.
# also github oidc credential is assigned. it uses variables in 'locals' file.

resource "azurerm_user_assigned_identity" "oidc_identity" {
  location            = var.location
  name                = "${var.prefix}-${var.environment}-github-oidc
  resource_group_name = azurerm_resource_group.aks-resources.name
}

resource "azurerm_federated_identity_credential" "oidc_credential" {
  name                = "${var.github_organisation_target}-${var.github_repo_target}-${var.environment}"
  resource_group_name = azurerm_resource_group.aks-resources.name
  audience            = [local.default_audience_name]
  issuer              = local.github_issuer_url
  parent_id           = azurerm_user_assigned_identity.oidc_identity.id
  subject             = "repo:${var.github_organisation_target}/${var.github_repo_target}:environment:${var.environment}"
}