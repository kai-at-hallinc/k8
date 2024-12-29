variable "prefix" {
  type    = string
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "github_organisation_target" {
  type    = string
  default = "kai-at-hallinc"
}

variable "github_repo_target" {
  type    = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tfcontainer" {
  type    = string
  default = "tfstate"
}