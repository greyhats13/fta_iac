locals {
  # Cloud Infrastructure Naming Standard
  ## GCS Standard
  gcs_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gcs"
    Feature = "tfstate"
  }
  gcs_naming_standard = "${local.gcs_standard.Unit}-${local.gcs_standard.Env}-${local.gcs_standard.Code}-${local.gcs_standard.Feature}"

  ## VPC Standard
  vpc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "vpc"
    Feature = "main"
  }
  vpc_naming_standard = "${local.vpc_standard.Unit}-${local.vpc_standard.Env}-${local.vpc_standard.Code}-${local.vpc_standard.Feature}"

  ## Cloud KMS Standard
  kms_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "kms"
    Feature = "main"
  }
  kms_naming_standard = "${local.kms_standard.Unit}-${local.kms_standard.Env}-${local.kms_standard.Code}-${local.kms_standard.Feature}"

  ## Cloud DNS Standard
  dns_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "dns"
    Feature = "main"
  }
  dns_naming_standard = "${local.dns_standard.Unit}-${local.dns_standard.Env}-${local.dns_standard.Code}-${local.dns_standard.Feature}"

  ## Google Secret Manager Standard
  gsm_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gsm"
    Feature = "iac"
  }
  gsm_naming_standard = "${local.gsm_standard.Unit}-${local.gsm_standard.Env}-${local.gsm_standard.Code}-${local.gsm_standard.Feature}"

  ### Convert decrypted secrets from terraform.tfvars to a map (see data.tf)
  iac_secret_map = { for k, v in data.google_kms_secret.iac_secrets : k => v.plaintext }
  ### Merge the decrypted secrets with the generated secrets (see secret_generator.tf)
  iac_secret_merged = merge(
    local.iac_secret_map,
    {
      "atlantis_ssh_base64"      = base64encode(tls_private_key.atlantis_ssh.private_key_pem)
      "atlantis_password"        = random_password.atlantis_password.result
      "atlantis_github_secret"   = random_password.atlantis_github_secret.result
      "argocd_github_secret"     = random_password.argocd_github_secret.result
      "argocd_ssh_base64"        = base64encode(tls_private_key.argocd_ssh.private_key_pem)
      "sonarqube_admin_password" = random_password.sonarqube_admin_password.result
      "sonarqube_jdbc_password"  = random_password.sonarqube_jdbc_password.result
    }
  )

  ### Convert the merged secrets to a json for the Secret Manager
  iac_secrets_merged_json = jsonencode(local.iac_secret_merged)

  ## Github Repository Standard
  ### Repository for fta_iac
  repo_iac_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "repo"
    Feature = "iac"
  }

  ## Repository for fta_helm
  repo_gitops_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "repo"
    Feature = "gitops"
  }

  ## Google Compute Engine Standard
  gce_atlantis_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gce"
    Feature = "atlantis"
  }
  gce_atlantis_naming_standard = "${local.gce_atlantis_standard.Unit}-${local.gce_atlantis_standard.Env}-${local.gce_atlantis_standard.Code}-${local.gce_atlantis_standard.Feature}"
  ## Cloud SQL Standard
  cloudsql_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "cloudsql"
    Feature = "main"
  }
  cloudsql_naming_standard = "${local.cloudsql_standard.Unit}-${local.cloudsql_standard.Env}-${local.cloudsql_standard.Code}-${local.cloudsql_standard.Feature}"
  ## Google Kubernetes Engine Standard
  gke_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "gke"
    Feature = "main"
  }
  gke_naming_standard = "${local.gke_standard.Unit}-${local.gke_standard.Env}-${local.gke_standard.Code}-${local.gke_standard.Feature}"

  ## Firestore Standard
  firestore_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "firestore"
    Feature = "main"
  }

  # Kubernetes Addons
  ## External DNS Standard
  external_dns_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "helm"
    Feature = "external-dns"
  }
  ## Ingress Nginx Standard
  ingress_nginx_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "helm"
    Feature = "ingress-nginx"
  }
  ## Cert Manager Standard
  cert_manager_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "helm"
    Feature = "cert-manager"
  }
  ## Sonarqube Standard
  sonarqube_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "helm"
    Feature = "sonarqube"
  }

  ## Argo CD Standard
  argocd_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "helm"
    Feature = "argocd"
  }
}
