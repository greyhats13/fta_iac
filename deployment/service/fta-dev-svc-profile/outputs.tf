# Service account outputs
output "service_account_email" {
  value       = module.gsa.service_account_email
}

# Artifact registry outputs
output "artifact_repo_id" {
  value       = flatten(module.artifact_registry.*.repo_id)[0]
}

output "artifact_repo_name" {
  value       = flatten(module.artifact_registry.*.repo_name)[0]
}

output "firestore_index_id" {
  value       = module.firestore_index.firestore_index_id
}

output "firestore_index_name" {
  value       = module.firestore_index.firestore_index_name
}