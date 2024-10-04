# Application github repository
## Create a Github repository for the service
## Store the github action variables and secrets in the Github repository environment
module "repo_users" {
  source                 = "../../../modules/cicd/github_repo"
  standard               = local.svc_standard
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = false
  auto_init              = true
  gitignore_template     = "Python"
  license_template       = "apache-2.0"
  security_and_analysis = {
    advanced_security = {
      status = "enabled"
    }
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }
  topics                  = ["python", "fastapi", "docker", "firestore", "gcp", "kubernetes"]
  vulnerability_alerts    = true
  github_action_variables = local.github_action_variables
  github_action_secrets   = local.github_action_secrets
}

# Application Service Account for Workload Identity
## Create a service account for the application
## Assign the specified IAM role to the service account
## Bind the service account to the workload identity
module "gsa" {
  source     = "../../../modules/gcp/gsa"
  region     = var.region
  standard   = local.svc_standard
  name       = local.svc_naming_full
  project_id = data.google_project.current.project_id
  # roles to pull images from Artifact Registry and connect to Cloud SQL
  roles = [
    "roles/datastore.user",
    "roles/cloudtrace.agent",
    "roles/cloudprofiler.agent",
    "roles/logging.logWriter"

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
  standard    = local.svc_standard
  name        = local.svc_naming_full
  secret_data = jsonencode(local.app_secret) // Save the app secret in json format to the Secret Manager (see locals.tf)
}

# Firestore Database for application data
## Create a Firestore index for the application
module "firestore_index" {
  source          = "../../../modules/gcp/firestore/index"
  region          = var.region
  standard        = local.svc_standard
  project_id      = data.google_project.current.project_id
  database_name   = data.terraform_remote_state.cloud_deployment.outputs.firestore_name
  collection_name = local.svc_naming_full
  fields = [
    {
      "field_path" = "uuid"
      "order"      = "ASCENDING"
    },
    {
      "field_path" = "email"
      "order"      = "ASCENDING"
    },
  ]
}


# Artifact Registry for application container images
## Create a repository in Artifact Registry for the application
module "artifact_registry" {
  source                 = "../../../modules/gcp/artifact-registry"
  region                 = var.region
  standard               = local.svc_standard
  repository_id          = local.svc_naming_standard
  repository_format      = "DOCKER"
  repository_mode        = "STANDARD_REPOSITORY"
  cleanup_policy_dry_run = false
  cleanup_policies = {
    "delete-prerelease" = {
      action = "DELETE"
      condition = {
        tag_state  = "TAGGED"
        tag_prefix = ["alpha", "beta"]
        older_than = "2592000s"
      }
    }
    "keep-tagged-release" = {
      action = "KEEP"
      condition = {
        tag_state             = "TAGGED"
        tag_prefixes          = ["release"]
        package_name_prefixes = [local.svc_naming_standard]
      }
    }
    "keep-minimum-versions" = {
      action = "KEEP"
      most_recent_versions = {
        package_name_prefixes = [local.svc_naming_standard]
        keep_count            = 5
      }
    }
  }
}

# ArgoCD Application for application deployment
## Create an ArgoCD application for the application
module "argocd_app" {
  source        = "../../../modules/cicd/helm"
  region        = var.region
  standard      = local.svc_standard
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  values        = ["${file("manifest/${local.svc_standard.Feature}.yaml")}"]
  namespace     = "argocd"
  project_id    = data.google_project.current.project_id
  dns_name      = "${var.env}.${trimsuffix(data.terraform_remote_state.cloud_deployment.outputs.main_dns_name, ".")}"
  extra_vars = {
    argocd_namespace      = "argocd"
    source_repoURL        = "https://github.com/${data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname}"
    source_targetRevision = "HEAD"
    source_path = var.env == "dev" ? "charts/app/incubator/${local.svc_name}" : (
      var.env == "stg" ? "charts/app/test/${local.svc_name}" : "charts/app/stable/${local.svc_name}"
    )
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = var.env
    avp_type                               = "gcpsecretmanager"
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}