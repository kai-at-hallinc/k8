variable "location" {
  description = "Location of the resources to create."
  type        = string

}

variable "database_resource_group" {
  type        = string
  description = "The database resourcegroup name."
}

variable "database_server_name" {
  type        = string
  description = "The database server name."
}

variable "database_name" {
  type        = string
  description = "The database name."
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network id"
}

variable "private_dns_zone_virtual_network_link_name" {
  type        = string
  description = "The name of the private DNS zone virtual network link."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id for private endpoint."
}

variable "private_endpoint_name" {
  type        = string
  description = "The name of the private endpoint for postgresql database service."
}

variable "db_admin_username" {
  type        = string
  description = "Postgresql server's admin username."
  # sensitive   = true
}

variable "db_admin_password" {
  type        = string
  description = "Postgreqsl server's admin password."
  # sensitive   = true
}

variable "db_instance_sku_name" {
  type        = string
  description = "Azure postgres instance type name, eg. GP_Gen5_4"
}

variable "dataplatform_resource_group" {
  type        = string
  description = "Resourcegroup for dataplatform"
}

variable "dataplatform_postgresql_name" {
  type        = string
  description = "Postgresql in dataplatform"
}

variable "dataplatform_postgresql_private_endpoint_name" {
  type        = string
  description = "Private endpoint name for dataplatform postgres"
}