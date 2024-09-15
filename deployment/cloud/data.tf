# Retrieve the current project
data "google_project" "curent" {}

data "google_kms_secret" "iac_secrets" {
  for_each   = var.iac_secrets_ciphertext
  crypto_key = module.kms_main.cryptokey_id
  ciphertext = each.value
}