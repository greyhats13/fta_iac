# GCP Settings
variable "region" {
  type        = string
  description = "GCP region"
}

variable "name" {
  type        = string
  description = "The name of the secret"
}

variable "standard" {
  type = map(string)
  description = "The standard naming convention for resources."
}

# Google Secret Manager arguments
variable "secret_data" {
  description = "The secrets to be stored in the secret manager"
}
