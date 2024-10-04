output "firestore_id" {
  value       = google_firestore_database.database.id
  description = "The ID of the Firestore database."
}

output "firestore_name" {
  value       = google_firestore_database.database.name
  description = "The name of the Firestore database."
}