# ArgoCD Application for application deployment
## Create an ArgoCD application for the application
module "argocd_app" {
  source        = "../../../modules/cicd/helm"
  region        = var.region
  standard      = local.svc_standard
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-apps"
  values        = ["${file("manifest/${local.svc_standard.Feature}.yaml")}"]
  namespace     = "argocd"
  dns_name      = "${var.env}.${trimsuffix(data.terraform_remote_state.cloud_deployment.outputs.main_dns_name, ".")}"
  extra_vars = {
    argocd_namespace      = "argocd"
    source_repoURL        = "https://github.com/${data.terraform_remote_state.cloud_deployment.outputs.gitops_repo_fullname}"
    source_targetRevision = "HEAD"
    source_path = var.env == "dev" ? "charts/app/incubator/${local.svc_name}" : (
      var.env == "stg" ? "charts/app/test/${local.svc_name}" : "charts/app/stable/${local.svc_name}"
    )
    project                                = "default"
    destination_server                     = "https://kubernetes.default.svc"
    destination_namespace                  = var.env
    avp_type                               = "gcpsecretmanager"
    syncPolicy_automated_prune             = true
    syncPolicy_automated_selfHeal          = true
    syncPolicy_syncOptions_CreateNamespace = true
  }
}