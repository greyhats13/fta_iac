resource "google_service_account" "gsa" {
  project      = var.project_id
  account_id   = var.name
  display_name = "Service Account for ${var.name} service"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  count   = length(var.roles)
  project = var.project_id
  role    = var.roles[count.index]
  member  = "serviceAccount:${google_service_account.gsa.email}"
}

# Binding service account to service account token creator
resource "google_service_account_iam_binding" "binding" {
  count              = length(var.binding_roles)
  service_account_id = google_service_account.gsa.name
  role               = var.binding_roles[count.index]
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[${var.standard.Env}/${var.name}]"] // environment as namespace
}


