# this file creates required oidc utils for later infrastructure deployment.
# file uses resources from modules directory.

#deploy resource group
module "aks_resources" {
  source = "../../modules/resource_group"
  location = var.location
  prefix = var.prefix
  environment = var.environment
}

# deploy oidc_identity
module "oidc-identity" {
  source = "../../modules/identity"
  location = var.location
  prefix = var.prefix
  environment = var.environment
  github_organisation_target = var.github_organisation_target
  github_repo_target = var.github_repo_target
}

#deploy storage
module "storage" {
  source = "../../modules/storage"
  name = var.tfcontainer
  location = var.location
  prefix = var.prefix
  environment = var.environment
}