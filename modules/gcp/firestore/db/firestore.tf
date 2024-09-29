resource "google_firestore_database" "database" {
  project                     = var.project_id
  name                        = var.name
  location_id                 = var.region
  type                        = var.type
  concurrency_mode            = var.concurrency_mode
  app_engine_integration_mode = var.app_engine_integration_mode
}
