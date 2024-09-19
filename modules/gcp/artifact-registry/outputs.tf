output "repo_id" {
  value = var.standard.Env == "dev" ? google_artifact_registry_repository.repo.*.id : null
}

output "repo_name" {
  value = var.standard.Env == "dev" ? google_artifact_registry_repository.repo.*.name : null
}