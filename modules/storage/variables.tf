# this file defines variables for storage module

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

variable "tfcontainer" {
  type    = string
  default = "tfstate"
}