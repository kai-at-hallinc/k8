
variable "cluster_resource_group_name" {
  description = "Resource group name containing aks."
  type = string
}


variable "location" {
  description = "Location of the resources to create."
  type        = string
}

variable "kubernetes_namespace_name" {
  type = string
}

variable "kubernetes_cluster_name" {
  type = string
}

variable "ingress_static_ip_name" {
  type        = string
  description = "Name of ingress public static ip."
}

variable "env" {
  type = string
}

variable "project" {
  type        = string
  description = "The project name."
}
