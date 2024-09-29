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
### Github
variable "github_owner" {
  type        = string
  description = "Github owner"
}

variable "github_orgs" {
  type        = string
  description = "Github organization"
}

variable "github_repo" {
  type        = string
  description = "Github repository"
}

variable "github_oauth_client_id" {
  type        = string
  description = "Github OAuth client ID for ArgoCD"
}

### Atlantis

variable "atlantis_version" {
  type        = string
  description = "Atlantis version"
}

variable "atlantis_user" {
  type        = string
  description = "Atlantis username"
}

### ArgoCD
variable "argocd_version" {
  type        = string
  description = "ArgoCD version"
}

variable "argocd_vault_plugin_version" {
  type        = string
  description = "ArgoCD Vault plugin version"
}

### Secret Chipertext from terraform.tfvars
variable "iac_secrets_ciphertext" {
  description = "List of secrets ciphertext"
}

### SonarQube
variable "sonarqube_jdbc_user" {
  type        = string
  description = "SonarQube database user"
}

variable "sonarqube_jdbc_db" {
  type        = string
  description = "SonarQube database name"
}

variable "sonarqube_jdbc_port" {
  type        = number
  description = "SonarQube database port"
}
