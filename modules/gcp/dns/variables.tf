# GCP Settings
variable "region" {
  type        = string
  description = "GCP region"
}

variable "name" {
  type        = string
  description = "the Zone name to use"
}

# cloud dns arguments
variable "dns_name" {
  type        = string
  description = "the dns name to use"
}

variable "force_destroy" {
  type        = bool
  description = "the force destroy to use"
}

variable "visibility" {
  type        = string
  description = "the visibility to use"
  default     = "public"
}

variable "private_visibility_config" {
  type = object({
    networks = object({
      network_url = string
    })
    gke_clusters = object({
      gke_cluster_name = string
    })
  })
  description = "the private visibility config to use"
  default     = null
}
