
# Terraform Module for deploying AKS cluster : https://registry.terraform.io/modules/Azure/aks/azurerm/latest
module "aks" {
  source                           = "Azure/aks/azurerm"
  version                          = "9.3.0"
  resource_group_name              = var.aks_rg
  node_resource_group              = var.node_resource_group
  identity_type                    = "SystemAssigned"
  automatic_channel_upgrade        = "stable"
  prefix                           = var.prefix
  vnet_subnet_id                   = var.aks_subnet_id
  os_disk_size_gb                  = 80
  sku_tier                         = "Free" # can also be Free
  # TODO: change this when we'll have an AD
  role_based_access_control_enabled = true
  rbac_aad_managed                 = true
  
  # TODO: private_cluster_enabled - If true cluster API server will be exposed only on internal IP address and available only in cluster vnet.
  private_cluster_enabled          = false
  
  # deprecated
  #http_application_routing_enabled  = true

  azure_policy_enabled              = true
  enable_auto_scaling              = true
  enable_host_encryption           = false
  agents_min_count                 = 1
  agents_max_count                 = 2

  # Set agents_count to null to enable auto-scaling
  agents_count                     = null
  agents_size                      = var.aks_vm_size

  # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 100
  agents_pool_name                 = "exnodepool"
  agents_type                      = "VirtualMachineScaleSets"

  green_field_application_gateway_for_ingress = {
    name        = var.ingress_application_gateway_name
    subnet_cidr = var.ingress_application_gateway_subnet_cidr
  }

  /*  depracated
  ingress_application_gateway_enabled     = true
  ingress_application_gateway_name        = var.ingress_application_gateway_name
  ingress_application_gateway_subnet_cidr = var.ingress_application_gateway_subnet_cidr */

  network_policy                 = "azure"
  network_plugin                 = "azure"
  net_profile_dns_service_ip     = var.aks_dns_service_ip
  
  # deprecated
  # net_profile_docker_bridge_cidr = var.aks_docker_cidr
  
  net_profile_service_cidr       = var.aks_service_cidr
  enable_node_public_ip          = false

  log_analytics_workspace_enabled       = false
  cluster_log_analytics_workspace_name = var.cluster_log_analytics_workspace_name

}

# assign network contributor role to aks managed identity
resource "azurerm_role_assignment" "aks_subnet" {
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.cluster_identity.principal_id
}

# allocate public static ip for ingress
resource "azurerm_public_ip" "ingress_static_ip" {
  name = var.ingress_static_ip_name
  domain_name_label = "ghallocation-${var.env}"
  resource_group_name = var.aks_rg
  location = var.location
  sku = "Standard"
  allocation_method = "Static"
}