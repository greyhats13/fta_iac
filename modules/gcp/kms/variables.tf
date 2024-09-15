# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

# Standard Name
variable "name" {
  type        = string
  description = "KMS Standard Name"
}

# keyring arguments
variable "keyring_location" {
  type        = string
  description = "The location of the keyring"
}

# cryptokey arguments
variable "cryptokey_rotation_period" {
  type        = string
  description = "The rotation period of the cryptokey"
}

variable "cryptokey_destroy_scheduled_duration" {
  type        = string
  description = "The destroy scheduled duration of the cryptokey"
}

variable "cryptokey_purpose" {
  type        = string
  description = "The purpose of the cryptokey"
}

variable "cryptokey_version_template" {
  type        = map(string)
  description = "The version template of the cryptokey"
}

# service account arguments
variable "cryptokey_role" {
  type        = string
  description = "The role of the service account"
}
