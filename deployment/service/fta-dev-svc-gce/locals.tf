locals {
  svc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "svc"
    Feature = "gce"
  }
  svc_naming_standard = "${local.svc_standard.Unit}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_naming_full     = "${local.svc_standard.Unit}-${local.svc_standard.Env}-${local.svc_standard.Code}-${local.svc_standard.Feature}"
  svc_name            = "${local.svc_standard.Unit}_${local.svc_standard.Feature}"
}
