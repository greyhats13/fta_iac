# Google Kubernetes Engine (GKE) Module for Google Cloud Platform (GCP)

This Terraform module provisions a fully configurable Google Kubernetes Engine (GKE) cluster on GCP. It supports features such as private clusters, autoscaling, network policies, Binary Authorization, and DNS configuration. Additionally, it allows for flexible node pool setups with autoscaling, spot instances, and Shielded VM configurations.

## Features

- **GKE Cluster Creation**: Provisions a GKE cluster with customizable node pools, network policies, Binary Authorization, and DNS settings.
- **Private Cluster Configuration**: Supports the creation of private clusters with private nodes and master endpoints.
- **Cluster Autoscaling**: Configurable autoscaling for both the cluster and node pools.
- **Node Pool Management**: Create multiple node pools with various configurations, including spot instances and Shielded VMs.
- **Network Policies**: Supports network policies to control communication between Pods.
- **Binary Authorization**: Ensures only trusted container images are deployed.
- **DNS Configuration**: Custom DNS provider and domain settings for the cluster.
- **Master Authorized Networks**: Restrict access to the cluster master endpoint through specific CIDR blocks.
- **Workload Identity**: Configure GKE Workload Identity for better security and identity management in your cluster.

## Usage

```hcl
module "gke_cluster" {
  source = "<path_to_module_directory>"

  project_id              = "my-gcp-project"
  region                  = "us-central1"
  name                    = "my-cluster"
  enable_autopilot        = false
  issue_client_certificate = true
  vpc_self_link           = "https://www.googleapis.com/compute/v1/projects/my-project/global/networks/my-vpc"
  subnet_self_link        = "https://www.googleapis.com/compute/v1/projects/my-project/regions/us-central1/subnetworks/my-subnet"

  private_cluster_config = {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.0.0.0/28"
  }

  cluster_autoscaling = {
    enabled = true
    resource_limits = {
      cpu = {
        minimum = 1
        maximum = 100
      }
      memory = {
        minimum = 2
        maximum = 200
      }
    }
  }

  node_config = {
    on_demand_pool = {
      is_spot         = false
      node_count      = 3
      machine_type    = "n1-standard-1"
      disk_size_gb    = 100
      disk_type       = "pd-standard"
      service_account = "my-service-account@gcp-project.iam.gserviceaccount.com"
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["web", "api"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
  }

  autoscaling = {
    on_demand_pool = {
      min_node_count  = 1
      max_node_count  = 10
      location_policy = "ANY"
    }
  }

  network_policy = {
    enabled  = true
    provider = "CALICO"
  }

  dns_config = {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
    cluster_dns_domain = "my-cluster.local"
  }
}
```

## Inputs

| Name                               | Description                                                                                      | Type     | Default  | Required |
|------------------------------------|--------------------------------------------------------------------------------------------------|----------|----------|:--------:|
| `project_id`                       | The GCP project ID where the resources will be created.                                           | `string` | n/a      |   yes    |
| `region`                           | The GCP region where the cluster will be created.                                                 | `string` | n/a      |   yes    |
| `name`                             | The name of the GKE cluster.                                                                      | `string` | n/a      |   yes    |
| `enable_autopilot`                 | Whether to enable GKE Autopilot mode.                                                             | `bool`   | `false`  |    no    |
| `vpc_self_link`                    | The self-link of the VPC where the cluster will be created.                                       | `string` | n/a      |   yes    |
| `subnet_self_link`                 | The self-link of the subnet where the cluster will be created.                                    | `string` | n/a      |   yes    |
| `private_cluster_config`           | Configuration for private clusters, including private nodes and endpoints.                        | `object` | `null`   |    no    |
| `issue_client_certificate`         | Whether to issue a client certificate for authenticating to the cluster.                          | `bool`   | `false`  |    no    |
| `cluster_autoscaling`              | Configuration for cluster autoscaling, including resource limits.                                 | `object` | `null`   |    no    |
| `node_config`                      | Configuration for the node pools, including machine type, disk size, and spot instance settings.   | `map`    | `{}`     |    no    |
| `autoscaling`                      | Autoscaling configuration for node pools, including minimum and maximum nodes.                    | `map`    | `{}`     |    no    |
| `network_policy`                   | Network policy configuration for the cluster.                                                     | `object` | `null`   |    no    |
| `dns_config`                       | DNS configuration for the cluster, including DNS provider and domain settings.                    | `object` | `null`   |    no    |

## Outputs

| Name                          | Description                                                   |
|-------------------------------|---------------------------------------------------------------|
| `cluster_id`                   | The unique identifier of the GKE cluster.                     |
| `cluster_name`                 | The name of the GKE cluster.                                  |
| `cluster_location`             | The location (region or zone) of the GKE cluster.             |
| `cluster_self_link`            | The self-link of the GKE cluster.                             |
| `cluster_endpoint`             | The IP address of the Kubernetes master endpoint.             |
| `cluster_client_certificate`   | The base64-encoded public certificate for client authentication. |
| `cluster_client_key`           | The base64-encoded private key for client authentication.      |
| `cluster_ca_certificate`       | The base64-encoded root certificate for the cluster.          |
| `cluster_master_version`       | The version of the Kubernetes master for the GKE cluster.     |

## Notes

- **Private Cluster**: If creating a private cluster, make sure to configure both `enable_private_nodes` and `enable_private_endpoint` in `private_cluster_config`.
- **Autopilot Mode**: When `enable_autopilot` is set to `true`, the cluster is fully managed by GCP. Some configurations such as node pools and network policies are automatically handled by GCP.
- **Cluster Autoscaling**: Use the `cluster_autoscaling` object to define the resource limits for CPU and memory to optimize performance and cost.
- **Node Pools**: Multiple node pools with custom configurations can be defined, including spot instances and shielded VMs for added security.
- **Network Policies**: Enabling network policies (e.g., Calico) enhances security by controlling the communication between Pods within the cluster.
- **Binary Authorization**: Ensure trusted images are deployed by configuring `binary_authorization` to verify container integrity.

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform

## Resources Created

- **google_container_cluster**: The primary GKE cluster resource.
- **google_container_node_pool**: (Optional) Custom node pools for the GKE cluster.
- **google_service_account**: (Optional) Service account for the node pools.
- **google_project_iam_member**: (Optional) IAM role assignments for the service account.

## Troubleshooting

- **Node Pool Scaling Issues**: Check your autoscaling configurations in `autoscaling` for each node pool. Ensure that the `min_node_count` and `max_node_count` values are correctly set.
- **Kubernetes Master Endpoint Access**: If you're unable to connect to the master endpoint, verify that the CIDR blocks in `master_authorized_networks_config` allow your IP.
- **Network Policy Conflicts**: Ensure that network policies are compatible with your chosen `datapath_provider`.

## References

- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider - google_container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
```