# resource "kubernetes_manifest" "manifest" {
#   count    = var.create_managed_certificate ? 1 : 0
#   manifest = yamldecode(templatefile("manifest/managed-cert.yaml", { feature = var.standard.Feature, env = var.standard.Env, namespace = local.namespace, dns_name = var.dns_name }))
# }

resource "google_service_account" "gsa" {
  count        = var.create_gsa ? 1 : 0
  project      = var.project_id
  account_id   = local.sa_naming_standard
  display_name = "Service Account for helm ${local.sa_naming_standard}"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  count   = var.create_gsa ? length(var.gsa_roles) : 0
  project = var.project_id
  role    = var.gsa_roles[count.index]
  member  = "serviceAccount:${google_service_account.gsa[0].email}"
}

# binding service account to service account token creator
resource "google_service_account_iam_binding" "token_creator" {
  count              = var.create_gsa && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = var.standard.Feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.sa_naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-repo-server]",
  ]
}

# binding service account to workload identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count              = var.create_gsa && var.use_workload_identity ? 1 : 0
  service_account_id = google_service_account.gsa[0].name
  role               = "roles/iam.workloadIdentityUser"
  members = var.standard.Feature != "argocd" ? [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${local.sa_naming_standard}]"
    ] : [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-server]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-application-controller]",
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/${var.standard.Feature}-repo-server]",
  ]
}