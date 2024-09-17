# Helm Module with Google Service Account and Workload Identity for Kubernetes

This Terraform module deploys Helm charts in a Kubernetes cluster while optionally creating a Google Service Account (GSA) and binding it to Kubernetes Workload Identity. It supports advanced Helm configurations like setting values, managing namespaces, and optionally creating Google-managed certificates.

## Features

- **Helm Release Management**: Deploy Helm charts in Kubernetes with customizable values, set lists, and Helm-specific configurations.
- **Google Service Account (GSA) Creation**: Optionally create a Google Service Account and assign roles based on the module configuration.
- **Workload Identity Integration**: Automatically bind the GSA to a Kubernetes service account using Workload Identity for secure access to GCP services.
- **Namespace Management**: Automatically create namespaces for Helm releases.
- **Google-managed Certificate**: Optionally create a managed certificate resource for handling DNS SSL certificates.
- **Kubernetes Manifest Deployment**: Deploy additional Kubernetes manifests and resources post-Helm release.
  
## Usage

```hcl
module "external_dns" {
  source                      = "<path_to_module_directory>"
  region                      = "us-central1"
  project_id                  = "my-gcp-project"
  standard                    = {
    Unit    = "cicd"
    Code    = "external"
    Feature = "dns"
    Env     = "prod"
  }

  # Helm chart configuration
  repository                  = "https://charts.bitnami.com/bitnami"
  chart                       = "external-dns"
  create_service_account      = true
  use_workload_identity       = true
  google_service_account_role = ["roles/dns.admin"]
  values                      = ["${file("helm/external-dns.yaml")}"]
  
  # Helm set values for configuring external DNS
  helm_sets = [
    {
      name  = "provider"
      value = "google"
    },
    {
      name  = "google.project"
      value = "my-gcp-project"
    },
    {
      name  = "policy"
      value = "sync"
    }
  ]

  # Kubernetes-specific settings
  namespace        = "dns"
  create_namespace = true

  # Optional Google-managed certificate creation
  create_managed_certificate = false

  # Dependency on GKE cluster
  depends_on = [
    module.gke_main
  ]
}
```

## Inputs

| Name                       | Description                                                                                         | Type          | Default  | Required |
|----------------------------|-----------------------------------------------------------------------------------------------------|---------------|----------|:--------:|
| `region`                   | The GCP or AWS region where resources will be deployed.                                              | `string`      | n/a      |   yes    |
| `project_id`               | The GCP project ID for the resources.                                                               | `string`      | `null`   |   yes    |
| `standard`                 | Standard naming convention for the resources.                                                       | `map(string)` | `{}`     |   yes    |
| `repository`               | The Helm chart repository URL.                                                                      | `string`      | n/a      |   yes    |
| `chart`                    | The Helm chart name to deploy.                                                                      | `string`      | n/a      |   yes    |
| `override_name`            | Custom Helm release name (optional).                                                                | `string`      | `null`   |    no    |
| `repository_username`      | The username for the Helm repository (optional).                                                    | `string`      | `null`   |    no    |
| `repository_password`      | The password for the Helm repository (optional).                                                    | `string`      | `null`   |    no    |
| `helm_version`             | The version of the Helm chart to deploy (optional).                                                 | `string`      | `null`   |    no    |
| `values`                   | A list of Helm values files to use in the release.                                                  | `list(string)`| `[]`     |    no    |
| `helm_sets`                | List of Helm set values (non-sensitive).                                                            | `list(object)`| `[]`     |    no    |
| `helm_sets_sensitive`      | List of sensitive Helm set values (to avoid exposing secrets).                                      | `list(object)`| `[]`     |    no    |
| `helm_sets_list`           | List of Helm set values that use lists.                                                             | `list(object)`| `[]`     |    no    |
| `namespace`                | The Kubernetes namespace where the Helm release will be deployed.                                   | `string`      | `null`   |    no    |
| `create_namespace`         | Whether to create the namespace for the Helm release.                                               | `bool`        | `false`  |    no    |
| `create_service_account`   | Whether to create a Google Service Account (GSA) for the Helm release.                              | `bool`        | `false`  |    no    |
| `use_workload_identity`    | Whether to bind the GSA to Kubernetes Workload Identity.                                             | `bool`        | `false`  |    no    |
| `google_service_account_role` | List of IAM roles to assign to the Google Service Account (if created).                          | `list(string)`| `[]`     |    no    |
| `create_managed_certificate` | Whether to create a Google-managed certificate for the DNS domain.                                | `bool`        | `false`  |    no    |
| `dns_name`                 | The DNS domain name for the managed certificate (if enabled).                                        | `string`      | `null`   |    no    |
| `k8s_manifests`            | List of Kubernetes manifests to deploy after the Helm release.                                      | `list(string)`| `[]`     |    no    |
| `kubectl_manifests`        | List of kubectl manifests to apply after the Helm release.                                          | `list(string)`| `[]`     |    no    |
| `extra_vars`               | Extra variables to pass to the Helm template files (sensitive).                                     | `map(any)`    | `{}`     |    no    |

## Outputs

| Name         | Description                                        |
|--------------|----------------------------------------------------|
| `metadata`   | The metadata of the Helm release, including the name, version, and chart. |

## Notes

- **Google Service Account and Workload Identity**: If `create_service_account` and `use_workload_identity` are both set to `true`, the module will create a GSA and bind it to the Kubernetes service account using Workload Identity. This allows the Kubernetes service account to access GCP services securely.
- **Helm Values and Sets**: Use the `values`, `helm_sets`, `helm_sets_sensitive`, and `helm_sets_list` variables to customize the Helm chart deployment. Sensitive values (e.g., passwords, API keys) should be placed in `helm_sets_sensitive`.
- **Kubernetes Manifests**: Additional Kubernetes resources (e.g., custom manifests) can be deployed after the Helm release using the `k8s_manifests` and `kubectl_manifests` variables.
- **Google-managed Certificate**: To enable automatic certificate management for your DNS, set `create_managed_certificate = true` and provide the DNS name in `dns_name`.

## Requirements

- **Terraform** version >= 0.12
- **Helm** plugin for Terraform
- **Kubectl** provider for managing Kubernetes manifests
- **Google Cloud Provider** plugin for managing Google Service Accounts and IAM roles

## Resources Created

- **Google Service Account**: A Google Service Account for accessing GCP resources securely from Kubernetes.
- **Google IAM Role Bindings**: IAM roles attached to the created Google Service Account.
- **Helm Release**: A Helm release deployed in the specified Kubernetes namespace.
- **Kubernetes Namespace**: (Optional) A namespace in Kubernetes where the Helm release is deployed.
- **Managed Certificate**: (Optional) A Google-managed certificate for securing DNS domains.

## Troubleshooting

- **Workload Identity Binding**: If Workload Identity binding fails, ensure that the `project_id`, `namespace`, and service account annotations are correctly set.
- **Helm Deployment Errors**: Check the Helm release logs for any errors related to chart version, repository access, or values misconfiguration.
- **Google-managed Certificate**: Ensure that the DNS domain name is correctly configured and accessible for Google to issue the certificate.

## References

- [Google Kubernetes Engine Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [Helm Documentation](https://helm.sh/docs/)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Terraform Google Provider - google_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account)