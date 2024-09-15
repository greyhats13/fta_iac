resource "google_secret_manager_secret" "secret" {
  for_each  = var.secret_data
  secret_id = each.key

  labels = {
    "unit"    = var.standard.Unit
    "env"     = var.standard.Env
    "code"    = var.standard.Code
    "feature" = each.key
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
    "name"    = var.name
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  for_each    = var.secret_data
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = try(each.value.plaintext, each.value)
}
