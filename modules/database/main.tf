

resource "azurerm_postgresql_server" "pg_server" {
  name                = var.database_server_name
  location            = var.location
  resource_group_name = var.database_resource_group

  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password

  # sku_name   = "GP_Gen5_4"
  sku_name   = var.db_instance_sku_name
  version    = "11"
  storage_mb = 307200

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_database" "pg_database" {
  name                = var.database_name
  resource_group_name = var.database_resource_group
  server_name         = azurerm_postgresql_server.pg_server.name
  charset             = "UTF8"
  collation           = "en-US"
}


resource "azurerm_private_dns_zone" "pg_private_dns_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.database_resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgdb" {
  name                  = var.private_dns_zone_virtual_network_link_name
  resource_group_name   = var.database_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.pg_private_dns_zone.name
  virtual_network_id    = var.virtual_network_id
}


resource "azurerm_private_endpoint" "pgdb_primary" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.database_resource_group
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "privatepgdb"
    private_dns_zone_ids = [azurerm_private_dns_zone.pg_private_dns_zone.id]
  }

  private_service_connection {
    name                           = "pg-psconn"
    private_connection_resource_id = azurerm_postgresql_server.pg_server.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

# Refer to postgres db in dataplatform project and create a private connection for it

data "azurerm_postgresql_flexible_server" "dataplatform_postgresql" {
  name                = var.dataplatform_postgresql_name
  resource_group_name = var.dataplatform_resource_group
}

resource "azurerm_private_endpoint" "dataplatform_pgdb" {
  name                = var.dataplatform_postgresql_private_endpoint_name
  location            = var.location
  resource_group_name = var.database_resource_group
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "private-dataplatform-pgdb"
    private_dns_zone_ids = [azurerm_private_dns_zone.pg_private_dns_zone.id]
  }

  private_service_connection {
    name                           = "pg-dataplatform-psconn"
    private_connection_resource_id = data.azurerm_postgresql_flexible_server.dataplatform_postgresql.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}
