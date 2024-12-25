variable "tenant_name" {
  type = string
  description = "Either of tw or airpro"
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID."
}

variable "tenant_id" {
  type        = string
  description = "The AAD Tenant ID."
}

variable "location" {
  description = "Location of the resources to create."
  type        = string
}

variable "aks_vm_size" {
  type        = string
  description = "Size of AKS Virtual machine size."
}

variable "parent_resource_group_name" {
  type = string
  description = "Name of parent resource group with aks."
}

variable "project" {
  type        = string
  description = "The project name."
}

variable "env" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "private_endpoint_cidr" {
  type        = string
  description = "The private endpoint subnet address space."
}

variable "aks_cidr" {
  type        = string
  description = "The aks subnet address space."
}

variable "aks_service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service."
}

variable "aks_dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
}

variable "aks_docker_cidr" {
  type        = string
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. "
}

variable "ingress_application_gateway_subnet_cidr" {
  type        = string
  description = "The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to be allowed to access the ACR"
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of IPs to be allowed to access the ACR"
}

variable "db_admin_username" {
  type        = string
  description = "Postgresql server's admin username."
}

variable "db_admin_password" {
  type        = string
  description = "Postgreqsl server's admin password."
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
