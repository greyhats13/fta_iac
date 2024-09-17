# Write the private key to a local file with specific permissions
resource "local_file" "private_key" {
  content              = var.private_key_pem
  filename             = "${var.ansible_path}/id_rsa.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

# Create a Google Cloud Service Account with a specific naming convention
resource "google_service_account" "sa" {
  account_id   = "${var.name}-sa"
  display_name = "Service Account for ${var.name} instance"
}

# Assign the specified IAM role to the service account
resource "google_project_iam_member" "sa_iam" {
  project = var.project_id
  role    = var.service_account_role
  member  = "serviceAccount:${google_service_account.sa.email}"
}

# Create a Google Compute Engine instance with specified parameters
resource "google_compute_instance" "instance" {
  # Naming, machine type, and zone configuration
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  # Boot disk configuration
  boot_disk {
    initialize_params {
      type  = var.disk_type
      size  = var.disk_size
      image = var.image
    }
  }

  # Network interface configuration, including conditional public IP assignment
  network_interface {
    subnetwork = var.subnet_self_link
    dynamic "access_config" {
      for_each = var.is_public ? [var.access_config] : []
      content {
        nat_ip                 = access_config.value.nat_ip == "" ? null : access_config.value.nat_ip
        public_ptr_domain_name = access_config.value.public_ptr_domain_name == "" ? null : access_config.value.public_ptr_domain_name
        network_tier           = access_config.value.network_tier == "" ? null : access_config.value.network_tier
      }
    }
  }

  # Metadata for SSH key configuration
  metadata = {
    ssh-keys = "${var.linux_user}:${var.public_key_openssh}"
  }

  # Service account and scope configuration
  service_account {
    email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
  tags = [var.standard.Feature]
}

# Conditionally create a DNS record for the Compute Engine instance
resource "google_dns_record_set" "record" {
  count = var.create_dns_record ? 1 : 0
  name  = "${var.standard.Feature}.${var.dns_config.dns_name}"
  type  = var.dns_config.record_type
  ttl   = var.dns_config.ttl

  managed_zone = var.dns_config.dns_zone_name

  rrdatas = [google_compute_instance.instance.network_interface.0.access_config.0.nat_ip]
}

# Define firewall rules for the Compute Engine instance
resource "google_compute_firewall" "firewall" {
  for_each = var.firewall_rules
  name     = "${var.name}-allow-${each.key}"
  network  = var.network_self_link

  # Dynamic block to iterate over firewall rules
  dynamic "allow" {
    for_each = var.firewall_rules
    content {
      protocol = each.value.protocol
      ports    = each.value.ports
    }
  }
  priority      = var.priority
  source_ranges = var.source_ranges
  target_tags   = [var.standard.Feature]
}

# Create a local file with Ansible variables if Ansible is to be run
resource "local_file" "ansible_vars" {
  count    = var.run_ansible ? 1 : 0
  content  = jsonencode(var.ansible_vars)
  filename = "${var.ansible_path}/ansible_vars.json"
}

# Conditionally run Ansible playbook with complex logic for tags and skip-tags
resource "null_resource" "ansible_playbook" {
  count = var.run_ansible ? 1 : 0
  provisioner "local-exec" {
    # Complex logic to handle different combinations of public IP, tags, and skip-tags
    command = var.is_public && length(var.ansible_skip_tags) > 0 ? "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${google_compute_instance.instance.network_interface.0.access_config.0.nat_ip}, -u ${var.linux_user} --private-key=${var.ansible_path}/id_rsa.pem ${var.ansible_path}/playbook.yml  --extra-vars '@${var.ansible_path}/ansible_vars.json' --tags ${join(",", var.ansible_tags)} --skip-tags ${join(",", var.ansible_skip_tags)}" : (
      var.is_public && length(var.ansible_skip_tags) <= 0 ? "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${google_compute_instance.instance.network_interface.0.access_config.0.nat_ip}, -u ${var.linux_user} --private-key=${var.ansible_path}/id_rsa.pem ${var.ansible_path}/playbook.yml  --extra-vars '@${var.ansible_path}/ansible_vars.json' --tags ${join(",", var.ansible_tags)}" : (
        !var.is_public && length(var.ansible_skip_tags) > 0 ? "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${google_compute_instance.instance.network_interface.0.network_ip}, -u ${var.linux_user} --private-key=${var.ansible_path}/id_rsa.pem ${var.ansible_path}/playbook.yml  --extra-vars '@${var.ansible_path}/ansible_vars.json' --tags ${join(",", var.ansible_tags)} --skip-tags ${join(",", var.ansible_skip_tags)}" : "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${google_compute_instance.instance.network_interface.0.network_ip}, -u ${var.linux_user} --private-key=${var.ansible_path}/id_rsa.pem ${var.ansible_path}/playbook.yml  --extra-vars '@${var.ansible_path}/ansible_vars.json' --tags ${join(",", var.ansible_tags)}"
      )
    )
  }

  # Clean up the Ansible variables file after playbook execution
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ansible/atlantis/ansible_vars.json ansible/atlantis/id_rsa.pem"
  }

  # Trigger to re-run playbook if it changes
  triggers = {
    playbook_checksum = filesha256("${var.ansible_path}/playbook.yml")
  }

  # Dependencies to ensure correct order of execution
  depends_on = [
    local_file.ansible_vars,
    google_compute_instance.instance,
    google_dns_record_set.record
  ]
}
