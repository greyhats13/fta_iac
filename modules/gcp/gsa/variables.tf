# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for the service."
}

# service account arguments
variable "name" {
  type        = string
  description = "The name of the google service account to create."
}

variable "roles" {
  type        = list(string)
  description = "The role to assign to the service account."
}

variable "binding_roles" {
  type        = list(string)
  description = "The binding role to assign to the service account."
}

