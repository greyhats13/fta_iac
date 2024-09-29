# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project id where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for resources."
}

variable "name" {
  type        = string
  description = "The name of the Firestore database."
  default     = "(default)"
}

variable "type" {
  type        = string
  description = "The type of the database."
}

variable "concurrency_mode" {
  type        = string
  description = "The concurrency mode of the database."
}

variable "app_engine_integration_mode" {
  type        = string
  description = "The app engine integration mode of the database."
  default     = "DISABLED"
}
