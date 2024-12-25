variable "location" {
  description = "Location of the resources to create."
  type        = string

}

variable "container_registry_resource_group" {
  type        = string
  description = "The container registry resourcegroup name."
}

variable "container_registry_name" {
  type        = string
  description = "The container registry name."
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to be allowed to access the ACR"
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of IPs to be allowed to access the ACR"
}