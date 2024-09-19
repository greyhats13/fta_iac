# Service account outputs
output "service_account_email" {
  value       = module.gsa.service_account_email
}

# Artifact registry outputs
output "artifact_repo_id" {
  value       = module.artifact_registry.repo_id
}

output "artifact_repo_name" {
  value       = module.artifact_registry.repo_name
}