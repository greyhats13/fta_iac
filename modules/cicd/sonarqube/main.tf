resource "sonarqube_alm_github" "github-alm" {
  app_id         = var.app_id
  client_id      = var.client_id
  client_secret  = var.client_secret
  key            = var.key
  private_key    = var.private_key
  url            = var.url
  webhook_secret = var.webhook_secret
}

resource "sonarqube_project" "main" {
  name       = "SonarQube"
  project    = "my_project"
  visibility = "public"
}
resource "sonarqube_github_binding" "github-binding" {
  alm_setting = sonarqube_alm_github.github-alm.key
  project     = "my_project"
  repository  = "myorg/myrepo"
}
