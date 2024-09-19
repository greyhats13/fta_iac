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

# # global address arguments
# variable "global_address_purpose" {
#   type        = string
#   description = "The purpose of the global address."
# }

# variable "global_address_type" {
#   type        = string
#   description = "The type of the global address."
# }

# variable "allocated_ip_range" {
#   type        = string
#   description = "The CIDR range to allocate for private service access. If null, prefix_length is used."
#   default     = null
# }

# variable "prefix_length" {
#   type        = number
#   description = "The prefix length of the IP range to allocate for private service access. Used if allocated_ip_range is null."
# }

# # Service Networking arguments
# variable "service_name" {
#   type        = string
#   description = "Provider peering service that is managing peering connectivity for a service provider organization"
# }

# Cloud SQL Instance Arguments
variable "database_version" {
  type        = string
  description = "The database engine type and version (e.g., POSTGRES_13, MYSQL_8_0)."
  default     = "POSTGRES_15"
}

variable "vpc_id" {
  type        = string
  description = "The VPC network where the Cloud SQL instance will be created."
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
      ipv4_enabled                                  = bool
      private_network                               = optional(string)
      ssl_mode                                      = string
      enable_private_path_for_google_cloud_services = optional(bool)
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
