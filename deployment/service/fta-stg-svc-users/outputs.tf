# Service account outputs
output "service_account_email" {
  value = module.gsa.service_account_email
}

# Artifact registry outputs
output "artifact_repo_id" {
  value = module.artifact_registry.*.repo_id !=  null ? flatten(module.artifact_registry.*.repo_id)[0] : null
}

output "artifact_repo_name" {
  value = module.artifact_registry.*.repo_name !=  null ? flatten(module.artifact_registry.*.repo_name)[0] : null
}