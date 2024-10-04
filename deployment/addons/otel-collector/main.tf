module "gsa" {
  source     = "../../../modules/gcp/gsa"
  region     = var.region
  standard   = local.addon_standard
  name       = local.addon_naming_full
  project_id = data.google_project.current.project_id
  # roles to pull images from Artifact Registry and connect to Cloud SQL
  roles = [
    "roles/cloudtrace.agent",
    "roles/cloudprofiler.agent",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
  binding_roles = [
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
  ]
}

module "argocd_app" {
  source     = "../../../modules/cicd/helm"
  region     = var.region
  standard   = local.addon_standard
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  values     = ["${file("manifest/${local.addon_standard.Feature}.yaml")}"]
  namespace  = "argocd"
  project_id = data.google_project.current.project_id
  dns_name   = "${var.env}.${trimsuffix(data.terraform_remote_state.cloud_deployment.outputs.main_dns_name, ".")}"
  extra_vars = {
    argocd_namespace                       = "argocd"
    source_origin_repoURL                  = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    source_origin_chart                    = "opentelemetry-collector"
    source_origin_targetRevision           = "0.108.0"
    source_override_repoURL                = "git@github.com:${data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname}.git"
    source_override_targetRevision         = "main"
    source_override_path                   = "charts/addons/${local.addon_standard.Feature}/values.yaml"
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = local.addon_standard.Feature
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}
