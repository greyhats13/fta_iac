# Create a Google Service Account for KMS
resource "google_service_account" "service_account" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name} service account"
}

# Create a Google KMS Key Ring
resource "google_kms_key_ring" "keyring" {
  name     = "${var.name}-keyring"
  location = var.keyring_location
}

# Create a Google KMS Crypto Key
resource "google_kms_crypto_key" "cryptokey" {
  name                       = "${var.name}-cryptokey"
  key_ring                   = google_kms_key_ring.keyring.id
  rotation_period            = var.cryptokey_rotation_period
  destroy_scheduled_duration = var.cryptokey_destroy_scheduled_duration
  purpose                    = var.cryptokey_purpose
  version_template {
    algorithm = var.cryptokey_version_template.algorithm
    protection_level = var.cryptokey_version_template.protection_level
  }
  lifecycle {
    prevent_destroy = false
  }
}

# Bind the Service Account to the Crypto Key
resource "google_kms_crypto_key_iam_binding" "cryptokey_iam_binding" {
  crypto_key_id = google_kms_crypto_key.cryptokey.id
  role          = var.cryptokey_role
  members       = ["serviceAccount:${google_service_account.service_account.email}"]
}