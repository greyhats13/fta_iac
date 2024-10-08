# Outputs
output "instance_name" {
  value       = google_sql_database_instance.instance.name
  description = "The name of the Cloud SQL instance."
}

output "instance_connection_name" {
  value       = google_sql_database_instance.instance.connection_name
  description = "The connection name of the Cloud SQL instance."
}

output "instance_self_link" {
  value       = google_sql_database_instance.instance.self_link
  description = "The self-link of the Cloud SQL instance."
}

output "instance_ip_address" {
  value       = google_sql_database_instance.instance.ip_address.0.ip_address
  description = "The IP address of the Cloud SQL instance."
}