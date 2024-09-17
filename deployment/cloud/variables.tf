# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "unit" {
  type        = string
  description = "Business unit code."
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

# Terraform vars config

## Config

### Atlantis

variable "atlantis_version" {
  type        = string
  description = "Atlantis version"
}

variable "atlantis_user" {
  type       = string
  description = "Atlantis username"
}

### Github
variable "github_owner" {
  type        = string
  description = "Github owner"
}

variable "github_repo" {
  type        = string
  description = "Github repository"
}

variable "github_oauth_client_id" {
  type        = string
  description = "Github OAuth client ID for ArgoCD"
}

### Secret Chipertext from terraform.tfvars
variable "iac_secrets_ciphertext" {
  description = "List of secrets ciphertext"
}