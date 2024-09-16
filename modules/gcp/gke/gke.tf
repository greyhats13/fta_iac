# Create a GKE cluster with 2 node pools
resource "google_container_cluster" "cluster" {
  # Define the cluster name using variables
  name = var.name
  # Set the location based autopilot settings
  location = !var.enable_autopilot ? "${var.region}-a" : var.region
  # Enable autopilot if the variable is set, otherwise set to null
  enable_autopilot    = !var.enable_autopilot ? null : true
  deletion_protection = false
  dynamic "cluster_autoscaling" {
    # Configure cluster autoscaling if autopilot is not enabled
    for_each = !var.enable_autopilot ? [var.cluster_autoscaling] : []
    content {
      enabled = cluster_autoscaling.value.enabled
      # Define resource limits for autoscaling
      dynamic "resource_limits" {
        for_each = cluster_autoscaling.value.enabled ? cluster_autoscaling.value.resource_limits : {}
        content {
          resource_type = resource_limits.key
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }
    }
  }
  # Remove the default node pool if not in autopilot mode
  remove_default_node_pool = !var.enable_autopilot ? true : null
  initial_node_count       = 1

  # Configure master authentication with client certificate
  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  # Configure private cluster settings based on variables
  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config.enable_private_endpoint || var.private_cluster_config.enable_private_nodes ? [var.private_cluster_config] : []
    content {
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
    }
  }
  # Set binary authorization mode
  dynamic "binary_authorization" {
    for_each = var.binary_authorization != {} || var.binary_authorization.evaluation_mode != null ? [var.binary_authorization] : []
    content {
      evaluation_mode = binary_authorization.value.evaluation_mode
    }
  }

  # Configure network policy if not in autopilot mode and enabled
  dynamic "network_policy" {
    for_each = !var.enable_autopilot && var.network_policy.enabled ? [var.network_policy] : []
    content {
      enabled  = network_policy.value.enabled
      provider = network_policy.value.provider
    }
  }
  # Set datapath provider (Dataplane V2), incompatible with network policy
  datapath_provider = !var.network_policy.enabled ? var.datapath_provider : null
  # Define authorized networks for master access
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != {} ? [var.master_authorized_networks_config] : []
    content {
      # Define authorized networks
      dynamic "cidr_blocks" {
        for_each = [master_authorized_networks_config.value.cidr_blocks]
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
      # Enable access from GCP public IP ranges
      gcp_public_cidrs_access_enabled = master_authorized_networks_config.value.gcp_public_cidrs_access_enabled
    }
  }

  # Define IP allocation policy for cluster and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }
  # Set network and subnetwork links
  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link
  # Configure DNS settings
  dynamic "dns_config" {
    for_each = var.dns_config.cluster_dns != null ? [var.dns_config] : []
    content {
      cluster_dns        = dns_config.value.cluster_dns
      cluster_dns_scope  = dns_config.value.cluster_dns_scope
      cluster_dns_domain = dns_config.value.cluster_dns_domain
    }
  }
  # Configure workload identity settings
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  # Define resource labels for the cluster
  resource_labels = {
    name    = var.name
    unit    = var.standard.Unit
    env     = var.standard.Env
    code    = var.standard.Code
    feature = var.standard.Feature
  }
}

# Create an on-demand node pool
resource "google_container_node_pool" "nodepool" {
  for_each   = !var.enable_autopilot ? var.node_config : {}
  name       = each.key
  location   = !var.enable_autopilot ? "${var.region}-a" : var.region
  cluster    = google_container_cluster.cluster.name
  node_count = each.value.node_count

  # Define node configuration settings variables
  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = each.value.disk_type
    service_account = each.value.service_account
    oauth_scopes    = each.value.oauth_scopes
    tags            = each.value.tags
    # Configure shielded instance settings if secure boot is enabled
    dynamic "shielded_instance_config" {
      for_each = lookup(each.value, "shielded_instance_config", null) != null ? [1] : []
      content {
        enable_secure_boot          = each.value.shielded_instance_config.enable_secure_boot
        enable_integrity_monitoring = each.value.shielded_instance_config.enable_integrity_monitoring
      }
    }
    # Configure workload metadata config
    dynamic "workload_metadata_config" {
      for_each = lookup(each.value, "workload_metadata_config", null) != null ? [1] : []
      content {
        mode = each.value.workload_metadata_config.mode
      }
    }
    # Define node labels
    labels = {
      name    = "${var.name}-np-${each.key}"
      unit    = var.standard.Unit
      env     = var.standard.Env
      code    = var.standard.Code
      feature = var.standard.Feature
      type    = each.key
    }
  }

  # Configure node management settings for auto repair and upgrade
  dynamic "management" {
    for_each = var.node_management.auto_repair || var.node_management.auto_upgrade ? [1] : []
    content {
      auto_repair  = var.node_management.auto_repair
      auto_upgrade = var.node_management.auto_upgrade
    }
  }

  # Configure autoscaling settings for spot instances
  dynamic "autoscaling" {
    for_each = var.autoscaling[each.key] != {} ? [lookup(var.autoscaling, each.key)] : []
    content {
      min_node_count  = autoscaling.value.min_node_count
      max_node_count  = autoscaling.value.max_node_count
      location_policy = autoscaling.value.location_policy
    }
  }
  lifecycle {
    ignore_changes = [node_count]
  }
}
