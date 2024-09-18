locals {
  svc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "svc"
    Feature = "users"
  }
  svc_naming_standard = "${local.svc_standard.Unit}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_name            = "${local.svc_standard.Unit}_${local.svc_standard.Feature}"
  ## Environment variables that will be stored in Github repo environment for Github Actions
  github_action_variables = {
    service_name          = local.svc_name
    docker_repository_uri = "greyhats13/${local.svc_name}"
    gitops_repo_name      = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname
    repo_gitops_ssh       = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_ssh_clone_url
    gitops_path_dev       = "incubator/${local.svc_name}"
    gitops_path_stg       = "test/${local.svc_name}"
    gitops_path_prd       = "stable/${local.svc_name}"
  }
  ## Secrets that will be stored in Github repo environment for Github Actions
  github_action_secrets = merge(
    data.google_kms_secret.secrets,
    { "GITOPS_SSH_PRIVATE_KEY" = base64decode(jsondecode(data.google_secret_manager_secret_version.iac.secret_data)["argocd_ssh_base64"]) }
  )

  ## Secrets that will be stored in the Secret Manager
  app_secret = {
    "USERNAME" = local.svc_name
    "PASSWORD" = random_password.password.result
    "DATABASE" = "${local.svc_name}_db_${var.env}"
    "HOST"     = data.terraform_remote_state.cloud_deployment.outputs.cloudsql_instance_ip_address
    "PORT"     = "5432"
  }
}
