# Create a Google Compute VPC
# This VPC will serve as the primary network for other resources.
resource "google_compute_network" "vpc" {
  name                    = var.name
  auto_create_subnetworks = var.auto_create_subnetworks # Disable default subnets creation for more granular control
}

# Create a Google Compute Subnetwork within the VPC
# This subnetwork will be used by GKE and other resources within the VPC.
resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.name}-subnet"
  ip_cidr_range            = var.ip_cidr_range
  network                  = google_compute_network.vpc.self_link # Link to the VPC created above
  private_ip_google_access = true
  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_range
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Create a Google Compute Router
# This router will manage traffic routing and connect the VPC to external networks.
resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# Create a Google Compute External IP Address if NAT IP allocation is set to MANUAL_ONLY
# This IP will be used by the Cloud NAT for outbound traffic.
resource "google_compute_address" "address" {
  count  = var.nat_ip_allocate_option == "MANUAL_ONLY" ? 3 : 0
  name   = "${var.name}-address-${count.index}"
  region = google_compute_subnetwork.subnet.region
}

# Create a Google Compute NAT
# Cloud NAT allows VM instances without external IPs to access the internet.
# It uses either auto-allocated or manually specified IPs based on the configuration.
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = var.nat_ip_allocate_option == "MANUAL_ONLY" ? google_compute_address.address.*.self_link : [] # set to empty list if NAT IP allocation is set to AUTO_ONLY or DISABLED
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  # Define subnetworks that will use this Cloud NAT if "LIST_OF_SUBNETWORKS" is specified
  dynamic "subnetwork" {
    for_each = var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? var.subnetworks : []
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }
}

# Create default firewall rules

resource "google_compute_firewall" "firewall" {
  for_each = var.vpc_firewall_rules
  name     = "${var.name}-allow-${each.key}"
  network  = google_compute_network.vpc.self_link

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_ranges = each.value.source_ranges
  priority      = each.value.priority
}