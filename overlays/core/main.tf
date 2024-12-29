locals {
  parent_resource_group        = var.parent_resource_group_name
  container_registry           = "acr${var.project}${var.env}${var.tenant_name}"
  private_endpoint_subnet_name = "snet-pe-${var.project}-${var.env}-${var.tenant_name}"
  virtual_network_name         = "vnet-${var.project}-${var.env}-${var.tenant_name}"
  aks_subnet_name              = "snet-aks-${var.project}-${var.env}-${var.tenant_name}"
  aks_node_resource_group      = "rg-nodes-${var.project}-${var.env}-${var.tenant_name}"
  ingress_static_ip_name       = "ingress-static-ip"
}


module "network" {
  source                         = "../../modules/network"
  virtual_network_name           = local.virtual_network_name
  virtual_network_resource_group = local.parent_resource_group
  location                       = var.location
  vnet_cidr                      = var.vnet_cidr
  env                            = var.env
  project                        = var.project
  private_endpoint_subnet_name   = local.private_endpoint_subnet_name
  private_endpoint_cidr          = var.private_endpoint_cidr
  aks_subnet_name                = local.aks_subnet_name
  aks_cidr                       = var.aks_cidr
}

module "container_registry" {
  source                            = "../../modules/container_registry"
  container_registry_name           = local.container_registry
  container_registry_resource_group = local.parent_resource_group
  location                          = var.location
  allowed_ips                       = var.allowed_ips
  allowed_subnet_ids                = [module.network.private_endpoint_subnet_id, module.network.aks_subnet_id]

  depends_on = [module.network]
}