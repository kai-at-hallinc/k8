variable "prefix" {
  type    = string
  default = "github-oidc"
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
  default = "my_repo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tfcontainer" {
  type    = string
  default = "tfstate"
}