# this file defines variables for the identity module

variable "prefix" {
  description = "The prefix for resources in this example"
  type        = string
  default     = "hallinc-aks"
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

variable "github_organisation_target" {
  type    = string
  default = "kai-at-hallinc"
}

variable "github_repo_target" {
  type    = string
}