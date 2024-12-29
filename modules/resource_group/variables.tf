# this file defines variables for the resource group module

variable "prefix" {
  description = "The prefix for resources in this example"
  type        = string
  default     = "aks"
}

variable "location" {
  description = "The location for resources in this example"
  type        = string
  default     = "swedencentral"
}

variable "environment" {
  description = "The environment for resources in this example"
  type        = string
  default     = "stage"
}