# Retrieve the current project
data "google_project" "curent" {}

# Decrypt the secrets using the KMS key
data "google_kms_secret" "iac_secrets" {
  for_each   = var.iac_secrets_ciphertext
  crypto_key = module.kms_main.cryptokey_id
  ciphertext = each.value
}

# # Get IAC secrets value from the Secret Manager
# data "google_secret_manager_secret_version" "iac" {
#   secret = "iac"
# }