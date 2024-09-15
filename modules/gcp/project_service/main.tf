resource "google_project_service" "project" {
  for_each = var.services
  project  = var.project_id
  service  = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = var.disable_dependent_services
}
