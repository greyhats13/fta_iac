# Cloud DNS Module for Google Cloud Platform (GCP)

This Terraform module provisions a Cloud DNS Managed Zone on GCP, supporting both public and private zones with configurable visibility and optional integration with VPC networks and GKE clusters.

## Features

- **Managed Zone Creation**: Creates a Cloud DNS Managed Zone with specified DNS name and visibility.
- **Private Zone Configuration**: Supports private zones with optional VPC network and GKE cluster configurations.
- **Force Destroy Option**: Allows the managed zone to be destroyed without manual intervention, even if it contains records.

## Usage

```hcl
module "dns_zone" {
  source = "<path_to_module_directory>"

  name          = "example-zone"
  dns_name      = "example.com."
  force_destroy = false
  visibility    = "private" # "public" or "private"

  private_visibility_config = {
    networks = {
      network_url = "https://www.googleapis.com/compute/v1/projects/my-project/global/networks/my-network"
    }
    gke_clusters = {
      gke_cluster_name = "projects/my-project/locations/us-central1/clusters/my-gke-cluster"
    }
  }
}
```

## Inputs

| Name                      | Description                                                                                       | Type     | Default  | Required |
|---------------------------|---------------------------------------------------------------------------------------------------|----------|----------|:--------:|
| `region`                  | GCP region                                                                                        | `string` | n/a      |   yes    |
| `name`                    | The name of the DNS Managed Zone                                                                  | `string` | n/a      |   yes    |
| `dns_name`                | The DNS name of the zone (must end with a period, e.g., `example.com.`)                           | `string` | n/a      |   yes    |
| `force_destroy`           | If set to `true`, the managed zone will be deleted even if it contains DNS records                | `bool`   | `false`  |    no    |
| `visibility`              | The visibility of the zone, either `"public"` or `"private"`                                      | `string` | `"public"` |   no    |
| `private_visibility_config` | Configuration for private zones, including VPC networks and GKE clusters (required if `visibility` is `"private"`) | `object` | `null` | conditionally |

### `private_visibility_config` Object

When `visibility` is set to `"private"`, the `private_visibility_config` object can be used to specify VPC networks and GKE clusters that can see the zone.

- **`networks`** (object):
  - `network_url` (string): The URL of the VPC network.

- **`gke_clusters`** (object):
  - `gke_cluster_name` (string): The resource name of the GKE cluster.

## Outputs

| Name                   | Description                                    |
|------------------------|------------------------------------------------|
| `dns_id`               | The ID of the DNS Managed Zone                 |
| `dns_zone_name`        | The name of the DNS Managed Zone               |
| `dns_name`             | The DNS name of the zone                       |
| `dns_managed_zone_id`  | The managed zone ID, assigned by Cloud DNS     |
| `dns_name_servers`     | A list of name servers assigned to the zone    |
| `dns_zone_visibility`  | The visibility setting of the zone (`public` or `private`) |

## Notes

- **Public vs. Private Zones**: When creating a private zone, ensure that you provide the `private_visibility_config` with either VPC network(s) or GKE cluster(s) that should have access to the zone.
- **DNS Name Format**: The `dns_name` variable must end with a period (e.g., `example.com.`).
- **Force Destroy**: Use the `force_destroy` variable with caution. When set to `true`, it will delete the managed zone along with all its DNS records without additional confirmation.

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform

## Resources Created

- **google_dns_managed_zone**: The Cloud DNS Managed Zone with specified settings.

## Input Details

### `name`

- **Description**: The name of the DNS Managed Zone.
- **Type**: `string`
- **Required**: Yes

### `dns_name`

- **Description**: The DNS name of the zone. This should be a fully qualified domain name ending with a period.
- **Type**: `string`
- **Required**: Yes

### `force_destroy`

- **Description**: If set to `true`, allows the managed zone to be destroyed without manual intervention, even if it contains DNS records.
- **Type**: `bool`
- **Default**: `false`
- **Required**: No

### `visibility`

- **Description**: The visibility setting of the zone. Valid values are `"public"` or `"private"`.
- **Type**: `string`
- **Default**: `"public"`
- **Required**: No

### `private_visibility_config`

- **Description**: Configuration object for private zones, specifying VPC networks and/or GKE clusters.
- **Type**: `object`
- **Default**: `null`
- **Required**: Required if `visibility` is `"private"`

## Output Details

### `dns_id`

- **Description**: The ID of the DNS Managed Zone.
- **Type**: `string`

### `dns_zone_name`

- **Description**: The name of the DNS Managed Zone.
- **Type**: `string`

### `dns_name`

- **Description**: The DNS name of the zone.
- **Type**: `string`

### `dns_managed_zone_id`

- **Description**: The managed zone ID assigned by Cloud DNS.
- **Type**: `string`

### `dns_name_servers`

- **Description**: A list of name servers assigned to the zone.
- **Type**: `list(string)`

### `dns_zone_visibility`

- **Description**: The visibility setting of the zone (`public` or `private`).
- **Type**: `string`

## Troubleshooting

- **Authentication Errors**: Ensure that your Terraform execution environment has the necessary permissions to create and manage Cloud DNS resources.
- **Invalid DNS Name**: The `dns_name` must be a valid DNS name and end with a period.
- **Private Zone Configuration**: When creating a private zone, the `private_visibility_config` must include valid `network_url` for VPC networks or `gke_cluster_name` for GKE clusters.

## References

- [Google Cloud DNS Documentation](https://cloud.google.com/dns/docs)
- [Terraform Google Provider - google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)

---