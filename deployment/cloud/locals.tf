locals {
  # GCS Standard
  gcs_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gcs"
    Feature = "tfstate"
  }
  gcs_naming_standard = "${local.gcs_standard.Unit}-${local.gcs_standard.Env}-${local.gcs_standard.Code}-${local.gcs_standard.Feature}"

  # VPC Standard
  vpc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "vpc"
    Feature = "main"
  }
  vpc_naming_standard = "${local.vpc_standard.Unit}-${local.vpc_standard.Env}-${local.vpc_standard.Code}-${local.vpc_standard.Feature}"

  # KMS Standard
  kms_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "kms"
    Feature = "main"
  }
  kms_naming_standard = "${local.kms_standard.Unit}-${local.kms_standard.Env}-${local.kms_standard.Code}-${local.kms_standard.Feature}"

  # DNS Standard
  dns_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "dns"
    Feature = "main"
  }
  dns_naming_standard = "${local.dns_standard.Unit}-${local.dns_standard.Env}-${local.dns_standard.Code}-${local.dns_standard.Feature}"

  # Secret Manager Standard
  gsm_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gsm"
    Feature = "iac"
  }
  gsm_naming_standard = "${local.gsm_standard.Unit}-${local.gsm_standard.Env}-${local.gsm_standard.Code}-${local.gsm_standard.Feature }"

  ## JSON encode the secret in plaintext
  iac_secrets_json = jsonencode({for k,v in data.google_kms_secret.iac_secrets : k => v.plaintext})
  ## Decode the secrets in plaintext
  iac_secrets_map = jsondecode(module.gsm_iac.secret_version_data)

  # Github Repository Standard
  ## Repository for fta_iac
  repo_iac_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "repo"
    Feature = "iac"
  }
  
  ## Repository for fta_helm
  repo_helm_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "repo"
    Feature = "helm"
  }
}