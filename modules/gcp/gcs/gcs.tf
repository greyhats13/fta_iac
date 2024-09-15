// Google Cloud Storage Bucket Configuration
resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = "${var.region}"
  force_destroy = var.force_destroy
  public_access_prevention = var.public_access_prevention
}
