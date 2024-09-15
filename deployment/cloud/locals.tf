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
}

