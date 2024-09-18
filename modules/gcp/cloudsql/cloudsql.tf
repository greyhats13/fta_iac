# Reserve IP range for Private Service Access
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}-private-ip-address"
  purpose       = var.global_address_purpose
  address_type  = var.global_address_type
  network       = var.vpc_id
  prefix_length = var.prefix_length
}

# Create a Service Networking Connection
# This connection allows private services to be accessed from other VPCs.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = var.service_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Create a Cloud SQL Instance
resource "google_sql_database_instance" "instance" {
  name                = var.name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  depends_on          = [google_service_networking_connection.private_vpc_connection]
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
      ipv4_enabled                                  = var.settings.ip_configuration.ipv4_enabled
      private_network                               = var.settings.ip_configuration.private_network
      ssl_mode                                      = var.settings.ip_configuration.ssl_mode
      enable_private_path_for_google_cloud_services = var.settings.ip_configuration.enable_private_path_for_google_cloud_services

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
