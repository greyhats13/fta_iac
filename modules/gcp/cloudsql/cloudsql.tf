# Create a Cloud SQL Instance
resource "google_sql_database_instance" "instance" {
  name                = var.name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.settings.deletion_protection

  settings {
    tier              = var.settings.tier
    availability_type = var.settings.availability_type
    disk_type         = var.settings.disk_type
    disk_size         = var.settings.disk_size
    activation_policy = var.settings.activation_policy

    # Backup Configuration
    backup_configuration {
      enabled                        = var.settings.backup_configuration.enabled
      start_time                     = var.settings.backup_configuration.start_time
      location                       = var.settings.backup_configuration.location
      point_in_time_recovery_enabled = var.settings.backup_configuration.point_in_time_recovery_enabled
    }

    # Maintenance Window
    maintenance_window {
      day          = var.settings.maintenance_window.day
      hour         = var.settings.maintenance_window.hour
      update_track = var.settings.maintenance_window.update_track
    }

    # IP Configuration
    ip_configuration {
      ipv4_enabled    = var.settings.ip_configuration.ipv4_enabled
      private_network = var.settings.ip_configuration.private_network
      ssl_mode       = var.settings.ip_configuration.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.settings.ip_configuration.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    # Database Flags
    dynamic "database_flags" {
      for_each = var.settings.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }
}
