module "gcp_project" {
  source     = "../../modules/gcp/project-service"
  project_id = data.google_project.curent.project_id
  services = {
    # resource_manager = "cloudresourcemanager.googleapis.com",
    iam                = "iam.googleapis.com",
    gcs                = "storage.googleapis.com"
    cloud_dns          = "dns.googleapis.com",
    gce                = "compute.googleapis.com",
    gke                = "container.googleapis.com",
    secret_manager     = "secretmanager.googleapis.com",
    kms                = "cloudkms.googleapis.com",
    sql                = "sqladmin.googleapis.com",
    service_networking = "servicenetworking.googleapis.com"
    firestore          = "firestore.googleapis.com"
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

## Provisioning the Github repository for fta_gitops
module "repo_gitops" {
  source                 = "../../modules/cicd/github_repo"
  standard               = local.repo_gitops_standard
  visibility             = "public"
  has_issues             = true
  has_discussions        = true
  has_projects           = true
  has_wiki               = true
  delete_branch_on_merge = true
  auto_init              = true
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
  topics               = ["gitops", "helm", "devops", "argocd", "argocd-vault-plugin", "kubernetes"]
  vulnerability_alerts = true
  webhooks = {
    argocd = {
      configuration = {
        url          = "https://argocd.fta.blast.co.id/api/webhook"
        content_type = "json"
        insecure_ssl = false
        secret       = jsondecode(module.gsm_iac.secret_data)["argocd_github_secret"]
      }
      active = true
      events = ["push"]
    }
  }
  public_key              = data.tls_public_key.argocd_public_key.public_key_openssh
  ssh_key                 = base64decode(jsondecode(module.gsm_iac.secret_data)["argocd_ssh_base64"])
  is_deploy_key_read_only = false
  argocd_namespace        = module.argocd.k8s_ns_name
}

## Provisioning the Cloud DNS using the DNS module
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
  public_key_openssh   = data.tls_public_key.atlantis_public_key.public_key_openssh
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
  manage_ansible_file = false
  run_ansible         = false
  ansible_path        = "ansible/atlantis"
  ansible_tags        = ["setup_kubectl"]
  ansible_skip_tags   = []
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

## Provisioning the Cloud SQL instance using the Cloud SQL module
module "cloudsql_instance_main" {
  source     = "../../modules/gcp/cloudsql"
  region     = var.region
  project_id = data.google_project.curent.project_id
  standard   = local.cloudsql_standard
  name       = local.cloudsql_naming_standard
  vpc_id     = module.vpc_main.vpc_id
  # global_address_purpose = "VPC_PEERING"
  # global_address_type    = "INTERNAL"
  # prefix_length          = 16
  # service_name           = "servicenetworking.googleapis.com"
  database_version = "POSTGRES_16"
  settings = {
    tier                = "db-f1-micro" # Choose an appropriate machine type
    availability_type   = "ZONAL"       # "ZONAL" or "REGIONAL"
    disk_type           = "PD_SSD"      # "PD_SSD" or "PD_HDD"
    disk_size           = 10            # Disk size in GB
    activation_policy   = "ALWAYS"      # "ALWAYS", "NEVER", "ON_DEMAND"
    deletion_protection = false         # Set to true to prevent accidental deletion

    backup_configuration = {
      enabled                        = true
      start_time                     = "03:00" # Time in UTC
      location                       = var.region
      point_in_time_recovery_enabled = true
    }

    maintenance_window = {
      day          = 7        # 1 (Sunday) to 7 (Saturday)
      hour         = 3        # 0 to 23
      update_track = "stable" # "canary" or "stable"
    }

    ip_configuration = {
      ipv4_enabled = true
      # private_network                               = module.vpc_main.vpc_self_link
      ssl_mode                                      = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      enable_private_path_for_google_cloud_services = false
      authorized_networks = [
        {
          name  = "NAT IP"
          value = "34.101.198.203/32"
        }
      ]
    }

    database_flags = [] # Add any database flags if needed
  }
  depends_on = [module.gcp_project, module.vpc_main]
}

module "firestore_main" {
  source           = "../../modules/gcp/firestore/db"
  region           = var.region
  project_id       = data.google_project.curent.project_id
  standard         = local.firestore_standard
  name             = "(default)"
  type             = "FIRESTORE_NATIVE"
  concurrency_mode = "OPTIMISTIC"
  depends_on       = [module.gcp_project]
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
      cidr_block   = "103.104.0.0/16"
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
module "external_dns" {
  source                     = "../../modules/cicd/helm"
  region                     = var.region
  standard                   = local.external_dns_standard
  repository                 = "https://charts.bitnami.com/bitnami"
  chart                      = "external-dns"
  create_gsa                 = true
  use_workload_identity      = true
  project_id                 = data.google_project.curent.project_id
  gsa_roles                  = ["roles/dns.admin"]
  create_managed_certificate = false
  values                     = ["${file("manifest/${local.external_dns_standard.Feature}.yaml")}"]
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
module "ingress_nginx" {
  source           = "../../modules/cicd/helm"
  region           = var.region
  standard         = local.ingress_nginx_standard
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  values           = ["${file("manifest/${local.ingress_nginx_standard.Feature}.yaml")}"]
  namespace        = "ingress"
  create_namespace = true
  project_id       = data.google_project.curent.project_id
  dns_name         = trimsuffix(module.dns_main.dns_name, ".")
  depends_on = [
    module.gke_main,
    module.external_dns
  ]
}

## Cert Manager
## Cert Manager is a Kubernetes addon that automates the management and issuance of TLS certificates from various issuing sources.
module "cert_manager" {
  source           = "../../modules/cicd/helm"
  region           = var.region
  standard         = local.cert_manager_standard
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  project_id       = data.google_project.curent.project_id
  values           = ["${file("manifest/${local.cert_manager_standard.Feature}.yaml")}"]
  namespace        = "cert-manager"
  create_namespace = true
  depends_on = [
    module.gke_main
  ]
}

## Create Cluster Issuer for Cert Manager
resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = templatefile("manifest/cluster-issuer.yaml", {
    unit = var.unit
  })
  depends_on = [module.cert_manager]
}

## ArgoCD
## ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.
module "argocd" {
  source                = "../../modules/cicd/helm"
  region                = var.region
  standard              = local.argocd_standard
  repository            = "https://argoproj.github.io/argo-helm"
  chart                 = "argo-cd"
  values                = ["${file("manifest/${local.argocd_standard.Feature}.yaml")}"]
  namespace             = "argocd"
  create_namespace      = true
  create_gsa            = true
  use_workload_identity = true
  project_id            = data.google_project.curent.project_id
  gsa_roles             = ["roles/container.admin", "roles/secretmanager.secretAccessor"]
  dns_name              = trimsuffix(module.dns_main.dns_name, ".")
  extra_vars = {
    github_orgs      = var.github_orgs
    github_client_id = var.github_oauth_client_id
    ARGOCD_VERSION   = var.argocd_version
    AVP_VERSION      = var.argocd_vault_plugin_version
  }
  helm_sets_sensitive = [
    {
      name  = "configs.secret.githubSecret"
      value = jsondecode(module.gsm_iac.secret_data)["argocd_github_secret"]
    },
    {
      name  = "configs.secret.extra.dex\\.github\\.clientSecret"
      value = jsondecode(module.gsm_iac.secret_data)["github_oauth_client_secret"]
    },
  ]
  depends_on = [
    module.gke_main,
    module.external_dns,
    module.ingress_nginx,
    kubectl_manifest.cluster_issuer
  ]
}

# Cloud SQL for application database and user
## Create application database and user in Cloud SQL
module "sql_sonar_jdbc" {
  source        = "../../modules/gcp/sql"
  region        = var.region
  standard      = local.sonarqube_standard
  project_id    = data.google_project.curent.project_id
  instance_name = module.cloudsql_instance_main.instance_name
  database      = var.sonarqube_jdbc_db
  username      = var.sonarqube_jdbc_user
  password      = jsondecode(module.gsm_iac.secret_data)["sonarqube_jdbc_password"]
}

## Create Cluster Issuer for Cert Manager
resource "kubectl_manifest" "sonarqube_secret" {
  yaml_body = templatefile("manifest/sonarqube-secret.yaml", {
    password      = jsondecode(module.gsm_iac.secret_data)["sonarqube_admin_password"]
    jdbc-password = jsondecode(module.gsm_iac.secret_data)["sonarqube_jdbc_password"]
  })
  depends_on = [module.cert_manager]
}

## Cert Manager is a Kubernetes addon that automates the management and issuance of TLS certificates from various issuing sources.
module "sonarqube" {
  source                = "../../modules/cicd/helm"
  region                = var.region
  standard              = local.sonarqube_standard
  repository            = "https://SonarSource.github.io"
  chart                 = "sonarqube"
  project_id            = data.google_project.curent.project_id
  gsa_roles             = ["roles/cloudsql.client"]
  values                = ["${file("manifest/${local.cert_manager_standard.Feature}.yaml")}"]
  namespace             = "sonarqube"
  create_namespace      = true
  create_gsa            = true
  use_workload_identity = true
  dns_name              = trimsuffix(module.dns_main.dns_name, ".")
  extra_vars = {
    sonarqube_jdbc_url  = "jdbc:postgresql://${module.cloudsql_instance_main.instance_ip_address}:${var.sonarqube_jdbc_port}/${var.sonarqube_jdbc_db}"
    sonarqube_jdbc_user = var.sonarqube_jdbc_user
  }
  depends_on = [
    module.gke_main
  ]
}
