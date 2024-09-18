locals {
  svc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "svc"
    Feature = "users"
  }
  svc_naming_standard = "${local.svc_standard.Unit}-${local.svc_standard.Env}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_name            = "${local.svc_standard.Unit}_${local.svc_standard.Feature}"
  github_action_variables = {
    service_name          = local.svc_name
    docker_repository_uri = "greyhats13/${local.svc_name}"
    gitops_repo_name      = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname
    repo_gitops_ssh       = data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_ssh_clone_url
    chart_path = var.env == "dev" ? "incubator/${local.svc_name}" : (
      var.env == "stg" ? "test/${local.svc_name}" : "stable/${local.svc_name}"
    )
  }
  secret_map = { for k, v in data.google_kms_secret.secrets : k => v.plaintext }
  secret_merged = merge(
    data.google_kms_secret.secrets,
    { "GITOPS_SSH_PRIVATE_KEY" = base64decode(jsondecode(data.terraform_remote_state.cloud_deployment.outputs.gsm_iac_secret_data)["argocd_ssh_base64"]) }
  )
}

