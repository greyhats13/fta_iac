# Retrieve the current project
data "google_project" "curent" {}

# Decrypt the secrets using the KMS key
data "google_kms_secret" "iac_secrets" {
  for_each   = var.iac_secrets_ciphertext
  crypto_key = module.kms_main.cryptokey_id
  ciphertext = each.value
}

# Get Public Key from Private Key stored in Google Secret Manager
## Atlantis
data "tls_public_key" "atlantis_public_key" {
  private_key_openssh = base64decode(jsondecode(module.gsm_iac.secret_data)["atlantis_ssh_base64"])
}

## ArgoCD
data "tls_public_key" "argocd_public_key" {
  private_key_openssh = base64decode(jsondecode(module.gsm_iac.secret_data)["argocd_ssh_base64"])
}