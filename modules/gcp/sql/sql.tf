resource "google_sql_database_instance" "postgres" {
  name             = var.cloudsql_instance_name
  database_version = var.db_version
  region           = var.db_region != null ? var.db_region : var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }

    storage_auto_resize        = true
    storage_auto_resize_limit  = var.db_storage
    disk_size                  = var.db_storage
    disk_type                  = "PD_SSD"

    availability_type          = "REGIONAL"
  }

  project = var.project_id
}