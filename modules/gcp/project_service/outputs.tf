output "project_service_id" {
  value       = { for service in google_project_service.project : service.id => service.service }
  description = "The ID of the project service"
}
