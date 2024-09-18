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