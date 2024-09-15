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

# Secret Chipertext from terraform.tfvars
variable "iac_secrets_ciphertext" {
  description = "List of secrets ciphertext"
}