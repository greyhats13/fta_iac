resource "google_secret_manager_secret" "secret" {
  secret_id = var.name

  labels = {
    "unit"    = var.standard.Unit
    "env"     = var.standard.Env
    "code"    = var.standard.Code
    "feature" = var.standard.Feature
    "name"    = var.name
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  annotations = {
    "unit"    = var.standard.Unit
    "env"     = var.standard.Env
    "code"    = var.standard.Code
    "feature" = var.standard.Feature
    "name"    = var.name
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data
}
