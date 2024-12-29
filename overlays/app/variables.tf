
variable "parent_resource_group_name" {
  description = "Resource group name containing aks."
  type        = string
}


variable "location" {
  description = "Location of the resources to create."
  type        = string
}
variable "env" {
  type = string
}

variable "project" {
  type        = string
  description = "The project name."
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID."
}