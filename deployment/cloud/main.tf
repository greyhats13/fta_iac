# Backend configuration
terraform {
  backend "gcs" {
    bucket = "fta-mstr-gcs-tfstate"
    prefix = "fta/cloud/deployment"
  }
}

# Retrieve the current project
data "google_project" "curent" {}

module "gcp_project" {
  source     = "../../modules/gcp/project_service"
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
      # source ranges based on the environment
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
