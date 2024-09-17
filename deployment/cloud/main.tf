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

# Provisioning a Google Cloud Storage bucket for storing Terraform state
module "gcs_tfstate" {
  source                   = "../../modules/gcp/gcs"
  region                   = var.region
  name                     = local.gcs_naming_standard
  force_destroy            = true
  public_access_prevention = "enforced"
}

# Provisioning the KMS using the KMS module
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
  standard    = local.gsm_standard
  name        = local.gsm_naming_standard
  secret_data = local.iac_secrets_merged_json // Save the merged secret to the Secret Manager (see locals.tf)
}

# Provision the GitHub repository for the fta_iac
module "repo_iac" {
  source                 = "../../modules/cicd/github_repo"
  standard               = local.repo_iac_standard
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = true
  auto_init              = false
  gitignore_template     = "Terraform"
  license_template       = "apache-2.0"
  security_and_analysis = {
    advanced_security = {
      status = "enabled"
    }
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }
  topics               = ["terraform", "ansible", "iac", "devops", "gcp", "argocd", "kubernetes"]
  vulnerability_alerts = true
  webhooks = {
    atlantis = {
      configuration = {
        url          = "https://atlantis.fta.blast.co.id/events"
        content_type = "json"
        insecure_ssl = false
        secret       = jsondecode(module.gsm_iac.secret_data)["atlantis_github_secret"]
      }
      active = true
      events = ["push", "pull_request", "pull_request_review", "issue_comment"]
    }
  }
}

module "dns_main" {
  source        = "../../modules/gcp/dns"
  region        = var.region
  name          = local.dns_naming_standard
  dns_name      = "${var.unit}.blast.co.id."
  force_destroy = true
  visibility    = "public"
}

# Provisioning the VPC using the VPC module
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

# Provisioning VM for Atlantis (Terraform CI/CD)

module "gce_atlantis" {
  source               = "../../modules/gcp/gce"
  region               = var.region
  standard             = local.gce_atlantis_standard
  name                 = local.gce_atlantis_naming_standard
  zone                 = "${var.region}-a"
  project_id           = data.google_project.curent.project_id
  service_account_role = "roles/owner"
  linux_user           = var.atlantis_user
  public_key_openssh   = tls_private_key.atlantis_ssh.public_key_openssh
  private_key_pem      = base64decode(jsondecode(module.gsm_iac.secret_data)["atlantis_ssh_base64"])
  machine_type         = "e2-medium"
  disk_size            = 20
  disk_type            = "pd-standard"
  network_self_link    = module.vpc_main.vpc_self_link
  subnet_self_link     = module.vpc_main.subnet_self_link
  is_public            = true
  access_config = {
    nat_ip                 = ""
    public_ptr_domain_name = ""
    network_tier           = "STANDARD"
  }
  image             = "debian-cloud/debian-12"
  create_dns_record = true
  dns_config = {
    dns_name      = module.dns_main.dns_name
    dns_zone_name = module.dns_main.dns_zone_name
    record_type   = "A"
    ttl           = 300
  }
  run_ansible       = true
  ansible_path      = "ansible/atlantis"
  ansible_tags      = ["setup_kubectl"]
  ansible_skip_tags = []
  ansible_vars = {
    project_id              = data.google_project.curent.project_id
    cluster_name            = module.gke_main.cluster_name
    region                  = "${var.region}-a"
    github_orgs             = var.github_owner
    atlantis_version        = var.atlantis_version
    atlantis_user           = var.atlantis_user
    atlantis_domain         = "atlantis.${trimsuffix(module.dns_main.dns_name, ".")}" // remove the trailing dot
    atlantis_repo_allowlist = "github.com/${flatten(module.repo_iac.*.full_name)[0]}"
    # Decode the json secret data from the GSM module to a mao and pass it to the Ansible variables
    github_token      = jsondecode(module.gsm_iac.secret_data)["github_token_atlantis"]
    github_token_iac  = jsondecode(module.gsm_iac.secret_data)["github_token_iac"]
    github_secret     = jsondecode(module.gsm_iac.secret_data)["atlantis_github_secret"]
    atlantis_password = jsondecode(module.gsm_iac.secret_data)["atlantis_password"]
  }

  firewall_rules = {
    "ssh" = {
      protocol = "tcp"
      ports    = ["22"]
    }
    "http" = {
      protocol = "tcp"
      ports    = ["80"]
    }
    "atlantis" = {
      protocol = "tcp"
      ports    = ["4141"]
    }
    "https" = {
      protocol = "tcp"
      ports    = ["443"]
    }
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  depends_on    = [module.gsm_iac, module.repo_iac, module.dns_main]
}

# Provisioning the GKE cluster using the GKE module
module "gke_main" {
  # Naming standard
  source     = "../../modules/gcp/gke"
  region     = var.region
  project_id = data.google_project.curent.project_id
  standard   = local.gke_standard
  name       = local.gke_naming_standard
  # cluster arguments
  issue_client_certificate      = false
  vpc_self_link                 = module.vpc_main.vpc_self_link
  subnet_self_link              = module.vpc_main.subnet_self_link
  pods_secondary_range_name     = module.vpc_main.pods_secondary_range_name
  services_secondary_range_name = module.vpc_main.services_secondary_range_name
  enable_autopilot              = false
  cluster_autoscaling = {
    enabled = false
    resource_limits = {
      cpu = {
        minimum = 2
        maximum = 8
      }
      memory = {
        minimum = 4
        maximum = 32
      }
    }
  }
  binary_authorization = {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" # set to null to disable
  }
  network_policy = {
    enabled  = false
    provider = "CALICO"
  }
  datapath_provider = "ADVANCED_DATAPATH"

  master_authorized_networks_config = {
    cidr_blocks = {
      cidr_block   = "103.104.13.0/24"
      display_name = "my-home-public-ip"
    }
    gcp_public_cidrs_access_enabled = false
  }

  private_cluster_config = {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "192.168.0.0/28"
  }

  dns_config = {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
    cluster_dns_domain = "${local.gke_standard.Code}.${trimsuffix(module.dns_main.dns_name, ".")}"
  }

  # node pool only work when enable_autopilot = false
  node_config = {
    spot = {
      is_spot         = true
      node_count      = 2
      machine_type    = "e2-medium"
      disk_size_gb    = 20
      disk_type       = "pd-standard"
      service_account = "781497044301-compute@developer.gserviceaccount.com" #data.google_service_account.gcompute_engine_default_service_account.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["spot"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
      workload_metadata_config = {
        mode = "GKE_METADATA"
      }
    }
    # ondemand = {
    #   is_spot         = false
    #   node_count      = 1
    #   machine_type    = "e2-medium"
    #   disk_size_gb    = 20
    #   disk_type       = "pd-standard"
    #   service_account = "781497044301-compute@developer.gserviceaccount.com" #data.google_service_account.gcompute_engine_default_service_account.email
    #   oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    #   tags            = ["ondemand"]
    #   shielded_instance_config = {
    #     enable_secure_boot          = true
    #     enable_integrity_monitoring = false
    #   }
    #   workload_metadata_config = {
    #     mode = "GKE_METADATA"
    #   }
    # }
  }

  autoscaling = {
    ondemand = {
      min_node_count  = 2
      max_node_count  = 20
      location_policy = "BALANCED"
    }
    spot = {
      min_node_count  = 2
      max_node_count  = 20
      location_policy = "ANY"
    }
  }

  node_management = {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Kubernetes Addons

## External DNS
## External DNS is a Kubernetes addon that configures public DNS servers with information about exposed services to make them discoverable.
module "external-dns" {
  source                      = "../../modules/cicd/helm"
  region                      = var.region
  standard                    = local.external_dns_standard
  repository                  = "https://charts.bitnami.com/bitnami"
  chart                       = "external-dns"
  create_service_account      = true
  use_workload_identity       = true
  project_id                  = data.google_project.curent.project_id
  google_service_account_role = ["roles/dns.admin"]
  create_managed_certificate  = false
  values                      = ["${file("helm/${local.external_dns_standard.Feature}.yaml")}"]
  helm_sets = [
    {
      name  = "provider"
      value = "google"
    },
    {
      name  = "google.project"
      value = data.google_project.curent.project_id
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "zoneVisibility"
      value = module.dns_main.dns_zone_visibility
    }
  ]
  namespace        = "dns"
  create_namespace = true
  depends_on = [
    module.gke_main
  ]
}

## Nginx Ingress Controller
## Nginx Ingress Controller is an Ingress controller that manages external access to HTTP services in a Kubernetes cluster using Nginx.
module "helm_nginx" {
  source     = "../../modules/cicd/helm"
  region     = var.region
  standard   = local.ingress_nginx_standard
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  values     = ["${file("helm/${local.ingress_nginx_standard.Feature}.yaml")}"]
  namespace  = "ingress"
  create_namespace = true
  project_id = data.google_project.curent.project_id
  dns_name   = trimsuffix(module.dns_main.dns_name, ".")
  depends_on = [
    module.gke_main,
    module.external-dns
  ]
}
