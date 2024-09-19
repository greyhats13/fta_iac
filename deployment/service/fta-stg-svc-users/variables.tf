# Service naming standard
variable "region" {
  type        = string
  description = "GCP region"
}

# Naming Standard
variable "unit" {
  type        = string
  description = "Business unit code"
}

variable "env" {
  type        = string
  description = "Stage environment"
}

# Credentials
# Load github secret ciphertext
# variable "github_secret_ciphertext" {
#   type        = string
#   description = "GitHub webhook secret"
# }

variable "github_action_secrets_ciphertext" {
  type        = map(string)
  description = "GitHub action secrets"
}