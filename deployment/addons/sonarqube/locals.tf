locals {
  addon_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "addon"
    Feature = "sonarqube"
  }
  addon_naming_standard = "${local.addon_standard.Unit}-${local.addon_standard.Code}-${local.addon_standard.Feature}"
  addon_naming_full     = "${local.addon_standard.Unit}-${local.addon_standard.Env}-${local.addon_standard.Code}-${local.addon_standard.Feature}"
  addon_name            = "${local.addon_standard.Unit}_${local.addon_standard.Feature}"

  ## Secrets that will be stored in the Secret Manager
  app_secret = {
    "ADMIN_PASSWORD" = random_password.admin_password.result
    "JDBC_PASSWORD"  = random_password.jdbc_password.result
    "JDBC_DATABASE"  = "sonarqube_db"
    "JDBC_USERNAME"  = "sonarqube"
    "JDBC_HOST"      = data.terraform_remote_state.cloud_deployment.outputs.cloudsql_instance_ip_address
  }
}
