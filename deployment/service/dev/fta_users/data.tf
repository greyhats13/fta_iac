# Terraform state data kms cryptokey
data "google_project" "current" {}
data "terraform_remote_state" "cloud_deployment" {
  backend = "gcs"

  config = {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/cloud/deployment"
  }
}

# Decrypt list of secrets
data "google_kms_secret" "secrets" {
  for_each   = var.github_action_secrets_ciphertext
  crypto_key = data.terraform_remote_state.cloud_deployment.outputs.security_cryptokey_id
  ciphertext = each.value
}

data "google_secret_manager_secret_version" "iac" {
  secret = "fta-mstr-gsm-iac"
}