# Google Compute Engine (GCE) Module for Google Cloud Platform (GCP)

This Terraform module provisions Google Compute Engine (GCE) instances on GCP, supporting the configuration of compute instances with optional SSH key management, VPC networking, firewall rules, and DNS record creation.

## Features

- **GCE Instance Creation**: Provisions a GCE instance with configurable machine type, disk size/type, and networking options.
- **SSH Key Management**: Option to provision SSH access using provided keys.
- **Ansible Integration**: Supports running Ansible playbooks post instance provisioning.
- **Firewall Rules Configuration**: Enables flexible configuration of firewall rules for the instance.
- **DNS Record Creation**: Optionally creates a DNS record for the provisioned instance.
- **Service Account Setup**: Creates and assigns a GCP Service Account to the instance with specified IAM roles.

## Usage

```hcl
module "gce_instance" {
  source               = "<path_to_module_directory>"
  project_id           = "my-gcp-project"
  region               = "us-central1"
  zone                 = "us-central1-a"
  name                 = "my-instance"
  machine_type         = "n1-standard-1"
  disk_size            = 100
  disk_type            = "pd-standard"
  image                = "debian-cloud/debian-10"
  linux_user           = "admin"
  public_key_openssh   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."
  private_key_pem      = file("${path.module}/keys/id_rsa")
  is_public            = true
  network_self_link    = "https://www.googleapis.com/compute/v1/projects/my-project/global/networks/my-network"
  subnet_self_link     = "https://www.googleapis.com/compute/v1/projects/my-project/regions/us-central1/subnetworks/my-subnet"
  create_dns_record    = true
  dns_config           = {
    dns_name     = "example.com."
    record_type  = "A"
    ttl          = 300
    dns_zone_name = "example-zone"
  }
  firewall_rules = {
    http = {
      protocol = "tcp"
      ports    = [80, 443]
    }
  }
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
  run_ansible  = true
  ansible_path = "${path.module}/ansible"
  ansible_vars = {
    app_name = "myapp"
    env      = "prod"
  }
  ansible_tags     = ["install", "configure"]
  ansible_skip_tags = ["skip_this"]
}
```

## Inputs

| Name                     | Description                                                                                         | Type     | Default  | Required |
|--------------------------|-----------------------------------------------------------------------------------------------------|----------|----------|:--------:|
| `project_id`              | The Google Cloud Project ID where resources will be managed.                                        | `string` | n/a      |   yes    |
| `region`                  | The Google Cloud region where resources will be created.                                            | `string` | n/a      |   yes    |
| `zone`                    | The GCP zone within the region for resource placement.                                              | `string` | n/a      |   yes    |
| `name`                    | The name of the GCE instance.                                                                       | `string` | n/a      |   yes    |
| `machine_type`            | The machine type for the GCE instance (e.g., `n1-standard-1`).                                      | `string` | n/a      |   yes    |
| `disk_size`               | The size of the boot disk in GB.                                                                    | `number` | n/a      |   yes    |
| `disk_type`               | The type of boot disk to use (`pd-standard`, `pd-ssd`).                                             | `string` | n/a      |   yes    |
| `image`                   | The source image for the instance (e.g., `debian-cloud/debian-10`).                                 | `string` | n/a      |   yes    |
| `linux_user`              | The username for SSH access.                                                                        | `string` | n/a      |   yes    |
| `public_key_openssh`      | The public SSH key for instance access.                                                             | `string` | n/a      |   yes    |
| `private_key_pem`         | The private SSH key for instance access (used for Ansible).                                         | `string` | n/a      |   yes    |
| `is_public`               | Boolean flag to indicate if the instance should have a public IP.                                   | `bool`   | `false`  |    no    |
| `network_self_link`       | The self-link of the VPC network where the instance will be placed.                                 | `string` | n/a      |   yes    |
| `subnet_self_link`        | The self-link of the subnet within the network.                                                     | `string` | n/a      |   yes    |
| `create_dns_record`       | Whether to create a DNS record for the instance.                                                    | `bool`   | `false`  |    no    |
| `dns_config`              | A map containing DNS record configuration, including `dns_name`, `record_type`, `ttl`, and `dns_zone_name`. | `map`    | `{}`     |    no    |
| `firewall_rules`          | A map of firewall rules, with protocol and port range.                                              | `map`    | `{}`     |    no    |
| `source_ranges`           | List of source IP ranges allowed by firewall rules.                                                 | `list`   | `[]`     |    no    |
| `priority`                | Priority of firewall rules.                                                                         | `number` | `1000`   |    no    |
| `run_ansible`             | Whether to run an Ansible playbook as part of instance provisioning.                                | `bool`   | `false`  |    no    |
| `ansible_path`            | The path to the Ansible playbook to be executed.                                                    | `string` | n/a      |   no     |
| `ansible_vars`            | A map of variables to be passed to the Ansible playbook.                                            | `map`    | `{}`     |   no     |
| `ansible_tags`            | Tags to control which Ansible tasks are run.                                                        | `list`   | `[]`     |   no     |
| `ansible_skip_tags`       | Tags to control which Ansible tasks are skipped.                                                    | `list`   | `[]`     |   no     |

## Outputs

| Name             | Description                                           |
|------------------|-------------------------------------------------------|
| `public_ip`      | The public IP address assigned to the instance.       |
| `private_ip`     | The private IP address assigned to the instance.      |

## Notes

- **Public IPs**: Set `is_public = true` to assign a public IP. Use with caution in production environments.
- **Ansible Integration**: Ensure the Ansible path and variables are correctly configured before setting `run_ansible = true`.
- **DNS Record**: If `create_dns_record` is set to `true`, ensure that the DNS configuration (e.g., `dns_zone_name`, `dns_name`, `record_type`) is valid.

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform
- **Ansible** (optional, if `run_ansible` is set to `true`)

## Resources Created

- **google_compute_instance**: The GCE instance with specified configurations.
- **google_dns_record_set**: (Optional) DNS record for the instance.
- **google_compute_firewall**: Configured firewall rules for the instance.
- **google_service_account**: Service account assigned to the instance.
- **google_project_iam_member**: IAM role assignment to the service account.

## Troubleshooting

- **SSH Access**: Ensure the SSH keys are correctly provisioned, and the correct username is used.
- **Ansible Playbook Fails**: Check Ansible logs for issues with playbook execution, such as connectivity problems or misconfigured variables.
- **Firewall Rule Conflicts**: Verify that firewall rules are correctly configured with appropriate priority and source ranges.

## References

- [Google Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Terraform Google Provider - google_compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
```