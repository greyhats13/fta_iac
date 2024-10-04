module "gsa" {
  source     = "../../../modules/gcp/gsa"
  region     = var.region
  standard   = local.addon_standard
  name       = local.addon_naming_full
  project_id = data.google_project.current.project_id
  # roles to pull images from Artifact Registry and connect to Cloud SQL
  roles = [
    "roles/cloudsql.client",
  ]
  binding_roles = [
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
  ]
}

# Secret Manager for application secrets
## Save the app secret in json format to the Secret Manager
module "gsm" {
  source      = "../../../modules/gcp/secret-manager"
  region      = var.region
  standard    = local.addon_standard
  name        = local.addon_naming_full
  secret_data = jsonencode(local.app_secret) // Save the app secret in json format to the Secret Manager (see locals.tf)
}

# Cloud SQL for application database and user
## Create application database and user in Cloud SQL
module "sql" {
  source        = "../../../modules/gcp/sql"
  region        = var.region
  standard      = local.addon_standard
  project_id    = data.google_project.current.project_id
  instance_name = data.terraform_remote_state.cloud_deployment.outputs.cloudsql_instance_name
  database      = "sonarqube_db"
  username      = "sonarqube"
  password      = jsondecode(module.gsm.secret_data)["JDBC_PASSWORD"]
}

# ArgoCD Application for application deployment
## Create an ArgoCD application for the application
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
    source_origin_repoURL                  = "https://SonarSource.github.io/helm-chart-sonarqube"
    source_origin_chart                    = local.addon_standard.Feature
    source_origin_targetRevision           = "10.6.1"
    source_override_repoURL                = "git@github.com:${data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname}.git"
    source_override_targetRevision         = "main"
    source_override_path                   = "charts/addons/${local.addon_standard.Feature}/values.yaml"
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = local.addon_standard.Feature
    avp_type                               = "gcpsecretmanager"
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}

# resource "sonarqube_project" "main" {
#     name       = "SonarQube"
#     project    = "fta-platform"
#     visibility = "public" 

#     setting {
#         key   = "sonar.projectDescription"
#         value = "Project for Fita Platform"
#     }
# }