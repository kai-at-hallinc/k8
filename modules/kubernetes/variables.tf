variable "location" {
  description = "Location of the resources to create."
  type        = string
}

variable "aks_rg" {
  type        = string
  description = "The AKS resource group name."
}

variable "node_resource_group" {
  type        = string
  description = "Node resource group name"
}

variable "aks_vm_size" {
  type        = string
  description = "Size of AKS Virtual machine size."
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "prefix" {
  type        = string
  description = "prefix used for AKS resources"
}

variable "aks_subnet_id" {
  type        = string
  description = "AKS subnet id"
}

variable "ingress_static_ip_name" {
  type        =  string
  description = "Name of ingress public static ip."
}

variable "ingress_application_gateway_name" {
  type        = string
  description = "The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
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

variable "cluster_log_analytics_workspace_name" {
  type        = string
  description = "The name of the Analytics workspace"
}

