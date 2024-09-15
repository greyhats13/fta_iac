resource "google_dns_managed_zone" "zone" {
  name          = var.name
  dns_name      = var.dns_name
  description   = "Cloud DNS for ${var.dns_name}"
  force_destroy = var.force_destroy
  visibility    = var.visibility
  dynamic "private_visibility_config" {
    for_each = var.visibility == "private" ? [var.private_visibility_config] : []
    content {
      dynamic "networks" {
        for_each = private_visibility_config.value.networks != null ? [private_visibility_config.value.networks] : []
        content {
          network_url = networks.value.network_url
        }
      }
      dynamic "gke_clusters" {
        for_each = private_visibility_config.value.gke_clusters != null ? [private_visibility_config.value.gke_clusters] : []
        content {
          gke_cluster_name = gke_clusters.value.gke_cluster_name
        }
      }
    }
  }
}
