locals {
  parent_resource_group             = "${var.parent_resource_group_name}"
  container_registry                = "cr${var.project}${var.env}${var.tenant_name}"
  private_endpoint_subnet_name      = "snet-pe-${var.project}-${var.env}-${var.tenant_name}"
  virtual_network_name              = "vnet-${var.project}-${var.env}-${var.tenant_name}"
  aks_subnet_name                   = "snet-aks-${var.project}-${var.env}-${var.tenant_name}"
  aks_node_resource_group           = "rg-nodes-${var.project}-${var.env}-${var.tenant_name}"
  ingress_static_ip_name            = "ingress-static-ip"
}


data "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  resource_group_name = local.parent_resource_group
}
data "azurerm_subnet" "pe_subnet" {
  name                 = local.private_endpoint_subnet_name
  resource_group_name  = local.parent_resource_group
  virtual_network_name = local.virtual_network_name
}

## postgresql with private service endpoint, azurerm private dns zone and dnz zone virtual network link
module "database" {
  source                                      = "../../../modules/database"
  location                                    = var.location
  database_resource_group                     = local.parent_resource_group
  database_server_name                        = "ghallocation-psqlserver-${var.env}"
  db_admin_username                           = var.db_admin_username
  db_admin_password                           = var.db_admin_password
  database_name                               = "airpro_gh_db"
  virtual_network_id                          = data.azurerm_virtual_network.vnet.id
  subnet_id                                   = data.azurerm_subnet.pe_subnet.id
  private_endpoint_name                       = "pg-private-endpoint"
  private_dns_zone_virtual_network_link_name  = "pg-virtual-network-link"
  db_instance_sku_name                        = "GP_Gen5_2"
  dataplatform_resource_group                 = var.dataplatform_resource_group
  dataplatform_postgresql_name                = var.dataplatform_postgresql_name
  dataplatform_postgresql_private_endpoint_name = var.dataplatform_postgresql_private_endpoint_name
  depends_on = [ data.azurerm_subnet.pe_subnet]
}


