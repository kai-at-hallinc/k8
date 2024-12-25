variable "virtual_network_resource_group" {
  type        = string
  description = "The virtual network resourcegroup name."
}


variable "location" {
  description = "Location of the resources to create."
  type        = string
}

variable "project" {
  type        = string
  description = "The project name."
}

variable "env" {
  type = string
}

variable "virtual_network_name" {
  type        = string
  description = "The virtual network resource name."
}

variable "vnet_cidr" {
  type        = string
  description = "The virtual network address space."
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "The private endpoint subnet name"
}

variable "private_endpoint_cidr" {
  type        = string
  description = "The private endpoint subnet address space."
}

variable "aks_subnet_name" {
  type        = string
  description = "The aks subnet name."
}

variable "aks_cidr" {
  type        = string
  description = "The aks subnet address space."
}
