locals {
  svc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "svc"
    Feature = "profile"
  }
  svc_naming_standard = "${local.svc_standard.Unit}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_naming_full     = "${local.svc_standard.Unit}-${local.svc_standard.Env}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_name            = "${local.svc_standard.Unit}_${local.svc_standard.Feature}"
  ## Environment variables that will be stored in Github repo environment for Github Actions
  github_action_variables = {
    service_name          = local.svc_name
    docker_repository_uri = "greyhats13/${local.svc_name}"
    gitops_repo_name      = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_name
    repo_gitops_ssh       = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_ssh_clone_url
    gitops_path_dev       = "charts/app/incubator/${local.svc_name}"
    gitops_path_stg       = "charts/app/test/${local.svc_name}"
    gitops_path_prd       = "charts/app/stable/${local.svc_name}"
  }
  ## Secrets that will be stored in Github repo environment for Github Actions
  secret_map = { for k, v in data.google_kms_secret.secrets : k => v.plaintext }
  github_action_secrets = merge(
    local.secret_map,
    { "GITOPS_SSH_PRIVATE_KEY" = base64decode(jsondecode(data.google_secret_manager_secret_version.iac.secret_data)["argocd_ssh_base64"]) }
  )

  ## Secrets that will be stored in the Secret Manager
  app_secret = {
    "FIRESTORE_PROJECT_ID" = data.google_project.current.project_id
    "FIRESTORE_DATABASE"   = data.terraform_remote_state.cloud_deployment.outputs.firestore_name
    "FIRESTORE_COLLECTION" = local.svc_naming_full
  }
}
