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