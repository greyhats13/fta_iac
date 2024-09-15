# Backend configuration
terraform {
  backend "gcs" {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/cloud/deployment"
  }
}

# module "github_repository" {
#   source                 = "../../modules/cicd/repository"
#   env                    = var.env
#   repository_name        = "${var.unit}_${var.feature}"
#   repository_readme      = "This is the repository for ${var.unit}_${var.feature}"
#   visibility             = "public"
#   has_issues             = true
#   has_discussions        = true
#   has_projects           = true
#   has_wiki               = true
#   delete_branch_on_merge = true
#   auto_init              = true
#   gitignore_template     = "Terraform"
#   license_template       = "apache-2.0"
#   security_and_analysis = {
#     advanced_security = {
#       status = "enabled"
#     }
#     secret_scanning = {
#       status = "enabled"
#     }
#     secret_scanning_push_protection = {
#       status = "enabled"
#     }
#   }
#   topics               = ["terraform", "iac", "devops", "gcp", "argocd", "kubernetes"]
#   vulnerability_alerts = true
#   # list_of_protect_branch = ["main", "dev", "stg"]
#   # enforce_admins         = false
#   # required_pull_request_reviews = {
#   #   require_code_owner_reviews      = false
#   #   required_approving_review_count = 1
#   #   bypass_pull_request_allowances = {
#   #     users = ["greyhats13"]
#   #     teams = ["devops"]
#   #     apps  = ["github-actions"]
#   #   }
#   # }
#   # restrictions = {
#   #   users = ["greyhats13"]
#   #   teams = ["devops"]
#   #   apps  = ["github-actions"]
#   # }
#   webhooks = {
#     atlantis = {
#       configuration = {
#         url          = "https://atlantis.fta.blast.co.id/events"
#         content_type = "json"
#         insecure_ssl = false
#         secret       = data.google_kms_secret.github_secret.plaintext
#       }
#       active = true
#       events = ["push", "pull_request", "pull_request_review", "issue_comment"]
#     }
#     argocd = {
#       configuration = {
#         url          = "https://argocd.fta.blast.co.id/api/webhook"
#         content_type = "json"
#         insecure_ssl = false
#         secret       = data.google_kms_secret.github_secret.plaintext
#       }
#       active = true
#       events = ["push"]
#     }
#   }
#   teams_permission = {
#     technology = "pull"
#     devops     = "triage"
#   }
# }

module "gcp_project" {
  source     = "../../modules/gcp/project-service"
  project_id = data.google_project.curent.project_id
  services = {
    # resource_manager = "cloudresourcemanager.googleapis.com",
    iam            = "iam.googleapis.com",
    gcs            = "storage.googleapis.com"
    cloud_dns      = "dns.googleapis.com",
    gce            = "compute.googleapis.com",
    gke            = "container.googleapis.com",
    secret_manager = "secretmanager.googleapis.com",
    kms            = "cloudkms.googleapis.com",
  }
}

# Create a Google Cloud Storage bucket for storing Terraform state
module "gcs_tfstate" {
  source                   = "../../modules/gcp/gcs"
  region                   = var.region
  name                     = local.gcs_naming_standard
  force_destroy            = true
  public_access_prevention = "enforced"
}

# Deploy the KMS using the KMS module
module "kms_main" {
  source                               = "../../modules/gcp/kms"
  name                                 = local.kms_naming_standard
  region                               = var.region
  project_id                           = data.google_project.curent.project_id
  keyring_location                     = "global"
  cryptokey_rotation_period            = "2592000s"
  cryptokey_destroy_scheduled_duration = "86400s"
  cryptokey_purpose                    = "ENCRYPT_DECRYPT"
  cryptokey_version_template = {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
  cryptokey_role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

# Deploy the Google Secret Manager(GSM) using the Secret Manager module
module "gsm_iac" {
  source      = "../../modules/gcp/secret-manager"
  region      = var.region
  name        = local.gsm_naming_standard
  standard    = local.gsm_standard
  secret_data = data.google_kms_secret.iac_secrets
}

module "dns_main" {
  source        = "../../modules/gcp/dns"
  region        = var.region
  name          = local.dns_naming_standard
  dns_name      = "${var.unit}.blast.co.id."
  force_destroy = true
  visibility    = "public"
}

# Deploy the VPC using the VPC module
module "vpc_main" {
  source                  = "../../modules/gcp/vpc"
  region                  = var.region
  name                    = local.vpc_naming_standard
  auto_create_subnetworks = false
  ip_cidr_range           = "10.0.0.0/16"
  secondary_ip_range = [
    {
      range_name    = "pods-range"
      ip_cidr_range = "100.64.0.0/16"
    },
    {
      range_name    = "services-range"
      ip_cidr_range = "100.65.0.0/16"
    }
  ]
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  vpc_firewall_rules = {
    icmp = {
      name        = "allow-icmp"
      description = "Allow ICMP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 65534
    }
    internal = {
      name        = "allow-internal"
      description = "Allow internal traffic on the network."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      source_ranges = ["10.0.0.0/16"]
      priority      = 65534
    }
    ssh = {
      name        = "allow-ssh"
      description = "Allow SSH from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 65534
    }
    rdp = {
      name        = "allow-rdp"
      description = "Allow RDP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["3389"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 65534
    }
  }
  depends_on = [module.gcp_project]
}
