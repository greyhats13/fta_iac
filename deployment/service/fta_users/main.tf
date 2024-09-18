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
  gitignore_template     = "Node"
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
  topics                  = ["nodejs", "service", "docker", "postgresql", "gcp", "kubernetes"]
  vulnerability_alerts    = true
  github_action_variables = local.github_action_variables
  github_action_secrets   = local.secret_merged
}

module "gsa" {
  source     = "../../../modules/gcp/gsa"
  region     = var.region
  standard   = local.svc_standard
  name       = local.svc_naming_standard
  project_id = data.google_project.curent.project_id
  # roles to pull images from Artifact Registry and connect to Cloud SQL
  roles = [
    "roles/storage.objectViewer",
    "roles/cloudsql.client",
  ]
  binding_roles = [
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
  ]
}

# module "gsm" {
#   source      = "../../modules/gcp/secret-manager"
#   region      = var.region
#   standard    = local.svc_standard
#   name        = local.svc_naming_standard
#   secret_data = local.iac_secrets_merged_json // Save the merged secret to the Secret Manager (see locals.tf)
# }

