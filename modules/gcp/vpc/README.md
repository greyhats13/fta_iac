Sure, based on your Terraform code for the VPC module, here is the `README.md` in English:

```markdown
# VPC Module for Google Cloud Platform (GCP)

This Terraform module provisions a Virtual Private Cloud (VPC) on GCP, along with associated resources like subnetworks, routers, Cloud NAT, and firewall rules.

## Features

- **VPC Creation**: Provisions a VPC with the option to disable default subnet creation for granular control.
- **Subnetwork Creation**: Defines a subnetwork within the VPC with primary and secondary CIDR ranges.
- **Router Creation**: Sets up a Cloud Router to manage traffic routing and connect the VPC to external networks.
- **Cloud NAT Creation**: Allows VM instances without external IPs to access the internet, supporting both auto-allocated and manually specified IPs.
- **Firewall Rule Creation**: Configures firewall rules for the VPC based on provided specifications.

## Usage

```hcl
module "vpc" {
  source = "<path_to_module_directory>"

  region                   = "<GCP Region>"
  name                     = "<VPC Name>"
  auto_create_subnetworks  = false  # Set to true if you want to auto-create subnetworks

  ip_cidr_range = "<Primary CIDR Range>"  # e.g., "10.0.0.0/16"

  secondary_ip_range = [
    {
      range_name    = "<Pods Secondary Range Name>"
      ip_cidr_range = "<Pods CIDR Range>"  # e.g., "10.1.0.0/16"
    },
    {
      range_name    = "<Services Secondary Range Name>"
      ip_cidr_range = "<Services CIDR Range>"  # e.g., "10.2.0.0/20"
    }
  ]

  nat_ip_allocate_option             = "<NAT IP Allocation Option>"              # "AUTO_ONLY" or "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "<Source IP Ranges to NAT>"               # "ALL_SUBNETWORKS_ALL_IP_RANGES" or "LIST_OF_SUBNETWORKS"
  subnetworks = [
    {
      name                    = "<Subnetwork Name>"
      source_ip_ranges_to_nat = ["<Source IP Range>"]  # e.g., ["ALL_IP_RANGES"]
    }
  ]

  vpc_firewall_rules = {
    "ssh" = {
      name        = "allow-ssh"
      description = "Allow SSH access"
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 1000
    },
    "http" = {
      name        = "allow-http"
      description = "Allow HTTP access"
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 1000
    }
  }
}
```

## Inputs

| Name                                | Description                                                                                   | Type           | Default | Required |
|-------------------------------------|-----------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| `region`                            | The GCP region where resources will be created.                                               | `string`       | n/a     |   yes    |
| `name`                              | The name of the VPC.                                                                          | `string`       | n/a     |   yes    |
| `auto_create_subnetworks`           | Whether to auto-create subnetworks in the VPC.                                                | `bool`         | `true`  |    no    |
| `ip_cidr_range`                     | The primary IP CIDR range of the subnetwork.                                                  | `string`       | n/a     |   yes    |
| `secondary_ip_range`                | Secondary IP ranges for GKE pods and services.                                                | `list(object)` | `[]`    |   yes    |
| `nat_ip_allocate_option`            | The NAT IP allocation option. Valid values: `AUTO_ONLY`, `MANUAL_ONLY`.                       | `string`       | n/a     |   yes    |
| `source_subnetwork_ip_ranges_to_nat`| The source IP ranges to NAT. Valid values: `ALL_SUBNETWORKS_ALL_IP_RANGES`, `LIST_OF_SUBNETWORKS`. | `string` | n/a | yes |
| `subnetworks`                       | List of subnetworks to configure NAT for.                                                     | `list(object)` | `[]`    |    no    |
| `vpc_firewall_rules`                | Map of firewall rules to be applied to the VPC.                                               | `map(object)`  | `{}`    |    no    |

### Secondary IP Range Object

Each object in `secondary_ip_range` should have the following attributes:

- `range_name` (string): The name of the secondary IP range.
- `ip_cidr_range` (string): The CIDR range for the secondary IP.

### Subnetworks Object

Each object in `subnetworks` should have the following attributes:

- `name` (string): The name of the subnetwork.
- `source_ip_ranges_to_nat` (list of strings): The source IP ranges to NAT, e.g., `["ALL_IP_RANGES"]`.

### VPC Firewall Rules Object

Each entry in `vpc_firewall_rules` map should have the following attributes:

- `name` (string): The name of the firewall rule.
- `description` (string): Description of the firewall rule.
- `direction` (string): Direction of traffic to which this firewall applies. Either `INGRESS` or `EGRESS`.
- `allow` (list of objects):
  - `protocol` (string): The protocol for the rule. Example: `tcp`, `udp`.
  - `ports` (list of strings): The ports for the rule. Example: `["22"]`, `["80", "8080"]`.
- `source_ranges` (list of strings): Source IP ranges in CIDR format.
- `priority` (number): Priority of the firewall rule. Lower number means higher priority.

## Outputs

| Name                         | Description                                 |
|------------------------------|---------------------------------------------|
| `vpc_id`                     | The ID of the VPC being created.            |
| `vpc_self_link`              | The URI of the VPC being created.           |
| `vpc_gateway_ipv4`           | The IPv4 address of the VPC's gateway.      |
| `subnet_network`             | The network to which the subnetwork belongs.|
| `subnet_self_link`           | The URI of the subnetwork.                  |
| `subnet_ip_cidr_range`       | The IP CIDR range of the subnetwork.        |
| `pods_secondary_range_name`  | The name of the secondary IP range for pods.|
| `services_secondary_range_name` | The name of the secondary IP range for services. |
| `router_id`                  | The ID of the router being created.         |
| `router_self_link`           | The URI of the router being created.        |
| `nat_id`                     | The ID of the Cloud NAT being created.      |
| `firewall_ids`               | Map of firewall rule IDs.                   |
| `firewall_self_links`        | Map of firewall rule self-links.            |

## Example

Here is a more concrete example of how to use this module:

```hcl
module "vpc" {
  source = "./modules/vpc"

  region                  = "us-central1"
  name                    = "my-vpc"
  auto_create_subnetworks = false

  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range = [
    {
      range_name    = "pods"
      ip_cidr_range = "10.1.0.0/16"
    },
    {
      range_name    = "services"
      ip_cidr_range = "10.2.0.0/20"
    }
  ]

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  vpc_firewall_rules = {
    "ssh" = {
      name        = "allow-ssh"
      description = "Allow SSH access from anywhere"
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 1000
    },
    "http-https" = {
      name        = "allow-http-https"
      description = "Allow HTTP and HTTPS access"
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      priority      = 1000
    }
  }
}
```

## Resources Created

- **Google Compute Network**: The VPC network.
- **Google Compute Subnetwork**: The subnetwork within the VPC.
- **Google Compute Router**: Cloud Router for managing dynamic routing within the VPC.
- **Google Compute Router NAT**: Cloud NAT for allowing outbound internet access without external IPs.
- **Google Compute Address**: External IP addresses if NAT IP allocation is set to `MANUAL_ONLY`.
- **Google Compute Firewall**: Firewall rules as specified.

## Requirements

- Terraform version >= 0.12
- Google Cloud Provider plugin for Terraform

## Notes

- When `nat_ip_allocate_option` is set to `MANUAL_ONLY`, make sure to configure the necessary external IP addresses.
- The `auto_create_subnetworks` variable defaults to `true`. Set it to `false` if you want to manage subnetworks manually.
- Ensure that the service account running Terraform has the necessary permissions to create these resources.

## Author

- **Imam Arief Rahman* - [greyhats13](https://github.com/greyhats13)

---