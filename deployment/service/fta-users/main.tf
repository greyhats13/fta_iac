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
  license_template = "apache-2.0"
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
  topics               = ["nodejs", "service", "docker", "postgresql", "gcp", "kubernetes"]
  vulnerability_alerts = true
  github_action_secrets = local.secret_merged
}

# module "artifact_repository" {
#   source                 = "../../../../modules/gcp/storage/artifact-registry"
#   region                 = var.region
#   env                    = var.env
#   repository_id          = "${var.unit}-${var.env}-${var.code}-${var.feature}"
#   repository_format      = "DOCKER"
#   repository_mode        = "STANDARD_REPOSITORY"
#   cleanup_policy_dry_run = false
#   cleanup_policies = {
#     "delete-prerelease" = {
#       action = "DELETE"
#       condition = {
#         tag_state  = "TAGGED"
#         tag_prefix = ["alpha", "beta"]
#         older_than = "2592000s"
#       }
#     }
#     "keep-tagged-release" = {
#       action = "KEEP"
#       condition = {
#         tag_state             = "TAGGED"
#         tag_prefixes          = ["release"]
#         package_name_prefixes = ["${var.unit}-${var.env}-${var.code}-${var.feature}"]
#       }
#     }
#     "keep-minimum-versions" = {
#       action = "KEEP"
#       most_recent_versions = {
#         package_name_prefixes = ["${var.unit}-${var.env}-${var.code}-${var.feature}"]
#         keep_count            = 5
#       }
#     }
#   }
# }


# module "argocd_app" {
#   source         = "../../../../modules/cicd/helm"
#   region         = var.region
#   standard       = local.svc_standard
#   cloud_provider = "gcp"
#   repository     = "https://argoproj.github.io/argo-helm"
#   chart          = "argocd-apps"
#   values         = ["${file("helm/genai.yaml")}"]
#   namespace      = "cd"
#   project_id     = "${var.unit}-platform-${var.env}"
#   dns_name       = "dev.ols.blast.co.id" #trimsuffix(data.terraform_remote_state.dns_blast.outputs.dns_name, ".")
#   extra_vars = {
#     argocd_namespace      = "cd"
#     source_repoURL        = "https://github.com/blastcoid/ols_helm"
#     source_targetRevision = "HEAD"
#     source_path = var.env == "dev" || var.env == "mstr" ? "charts/incubator/${local.svc_name}" : (
#       var.env == "stg" ? "charts/test/${local.svc_name}" : "charts/stable/${local.svc_name}"
#     )
#     project                                = "default"
#     destination_server                     = "https://kubernetes.default.svc"
#     destination_namespace                  = var.env
#     avp_type                               = "gcpsecretmanager"
#     syncPolicy_automated_prune             = true
#     syncPolicy_automated_selfHeal          = true
#     syncPolicy_syncOptions_CreateNamespace = true
#   }
# }

# module "workload_identity" {
#   source                      = "../../../../modules/gcp/iam/workload-identity"
#   region                      = var.region
#   env                         = var.env
#   project_id                  = "${var.unit}-platform-${var.env}"
#   service_account_name        = "${var.unit}-${var.code}-${var.feature}"
#   google_service_account_role = "roles/datastore.user"
# }
