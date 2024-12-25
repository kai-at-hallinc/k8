locals {
  parent_resource_group             = "${var.parent_resource_group_name}"
  container_registry                = "acr${var.project}${var.env}${var.tenant_name}"
  private_endpoint_subnet_name      = "snet-pe-${var.project}-${var.env}-${var.tenant_name}"
  virtual_network_name              = "vnet-${var.project}-${var.env}-${var.tenant_name}"
  aks_subnet_name                   = "snet-aks-${var.project}-${var.env}-${var.tenant_name}"
  aks_node_resource_group           = "rg-nodes-${var.project}-${var.env}-${var.tenant_name}"
  ingress_static_ip_name            = "ingress-static-ip"
}

data "azurerm_container_registry" "acr" {
  name                = local.container_registry
  resource_group_name = local.parent_resource_group
}

data "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  resource_group_name = local.parent_resource_group
}

data "azurerm_subnet" "aks_subnet" {
  name                 = local.aks_subnet_name
  resource_group_name  = local.parent_resource_group
  virtual_network_name = local.virtual_network_name
}

module "kubernetes" {
  source                                  = "../../modules/kubernetes"
  location                                = var.location
  env                                     = var.env
  aks_rg                                  = local.parent_resource_group
  node_resource_group                     = local.aks_node_resource_group
  aks_vm_size                             = var.aks_vm_size
  prefix                                  = "${var.project}-${var.env}"
  aks_subnet_id                           = "${data.azurerm_subnet.aks_subnet.id}"
  ingress_static_ip_name                  = local.ingress_static_ip_name
  ingress_application_gateway_name        = "aks-agw-${var.project}-${var.env}-${var.tenant_name}"
  aks_service_cidr                        = var.aks_service_cidr
  aks_dns_service_ip                      = var.aks_dns_service_ip
  aks_docker_cidr                         = var.aks_docker_cidr
  ingress_application_gateway_subnet_cidr = var.ingress_application_gateway_subnet_cidr
  cluster_log_analytics_workspace_name    = "loa-${var.project}-${var.env}-${var.tenant_name}-aks"

  depends_on = [ data.azurerm_subnet.aks_subnet]
}

resource "azurerm_role_assignment" "aks_vnet" {
  scope                = data.azurerm_virtual_network.vnet.id
  role_definition_name = "Contributor"
  principal_id         = module.kubernetes.aks_principal_id

  depends_on = [ module.kubernetes]
}


resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                = "${data.azurerm_container_registry.acr.id}"
  role_definition_name = "AcrPull"
  principal_id         = module.kubernetes.kubelet_identity_object_id
  depends_on = [data.azurerm_container_registry.acr]
  #depends_on = [ module.container_registry, module.kubernetes]
}
