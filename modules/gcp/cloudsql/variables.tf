# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for resources."
}

variable "name" {
  type        = string
  description = "The name of the Cloud SQL instance."
}

# Cloud SQL Instance Arguments
variable "database_version" {
  type        = string
  description = "The database engine type and version (e.g., POSTGRES_13, MYSQL_8_0)."
  default     = "POSTGRES_15"
}

variable "settings" {
  type = object({
    tier                = string # Machine type (e.g., db-f1-micro, db-n1-standard-1)
    availability_type   = string # "ZONAL" or "REGIONAL"
    disk_type           = string # "PD_SSD" or "PD_HDD"
    disk_size           = number # Disk size in GB
    activation_policy   = string # "ALWAYS", "NEVER", "ON_DEMAND"
    deletion_protection = bool   # Whether deletion protection is enabled

    backup_configuration = object({
      enabled                        = bool
      start_time                     = string
      location                       = string
      point_in_time_recovery_enabled = bool
    })

    maintenance_window = object({
      day          = number # 1 (Sunday) to 7 (Saturday)
      hour         = number # 0 to 23
      update_track = string # "canary" or "stable"
    })

    ip_configuration = object({
      ipv4_enabled    = bool
      private_network = string
      ssl_mode        = string
      authorized_networks = list(object({
        name  = string
        value = string
      }))
    })

    database_flags = list(object({
      name  = string
      value = string
    }))
  })
  description = "Settings for the Cloud SQL instance."
}
