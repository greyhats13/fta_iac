# Project Service Module for Google Cloud Platform (GCP)

This Terraform module manages the enabling of Google Cloud services (APIs) within a GCP project.

## Features

- **Enable Services**: Activates specified Google Cloud services within a project.
- **Manage Dependencies**: Option to disable dependent services when disabling a service.
- **Customizable Timeouts**: Configure timeouts for creating and updating services.

## Usage

```hcl
module "project_services" {
  source = "<path_to_module_directory>"

  project_id = "<GCP Project ID>"
  services   = {
    "compute" = "compute.googleapis.com"
    "storage" = "storage.googleapis.com"
    # Add other services as needed
  }
  disable_dependent_services = true  # Optional, defaults to true
}
```

## Inputs

| Name                         | Description                                                                 | Type          | Default | Required |
|------------------------------|-----------------------------------------------------------------------------|---------------|---------|:--------:|
| `project_id`                 | The ID of the GCP project where services will be managed.                   | `string`      | n/a     |   yes    |
| `services`                   | A map of services to enable in the project.                                 | `map(string)` | `{}`    |   yes    |
| `disable_dependent_services` | Whether to disable services that are dependent on the service being disabled. | `bool`     | `true`  |    no    |

### Services Variable

The `services` variable is a map where:

- **Key**: An identifier for the service (e.g., `"compute"`, `"storage"`).
- **Value**: The service name as recognized by Google Cloud (e.g., `"compute.googleapis.com"`).

## Outputs

| Name                 | Description                          |
|----------------------|--------------------------------------|
| `project_service_id` | The ID of the project service.       |

## Example

```hcl
module "project_services" {
  source = "./modules/project_service"

  project_id = "my-gcp-project"
  services   = {
    "compute"        = "compute.googleapis.com"
    "storage"        = "storage.googleapis.com"
    "bigquery"       = "bigquery.googleapis.com"
    "cloudfunctions" = "cloudfunctions.googleapis.com"
  }
  disable_dependent_services = false
}
```

## Resources Managed

- **google_project_service**: Enables or disables Google Cloud services (APIs) for a project.

## Notes

- **Timeouts**: The module sets custom timeouts for creating (`30m`) and updating (`40m`) services to accommodate services that may take longer to enable.
- **Dependencies**: By default, `disable_dependent_services` is set to `true`, which means disabling a service will also disable any services that depend on it. Set this to `false` if you want to prevent dependent services from being disabled.
- **Service List**: You can find a list of all available services (APIs) in the [Google Cloud Service Name List](https://cloud.google.com/service-usage/docs/reference/rest/v1/services).

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform

## Inputs Detail

### `project_id`

- **Description**: The ID of the GCP project where services will be managed.
- **Type**: `string`
- **Required**: Yes

### `services`

- **Description**: A map of services to enable in the project.
- **Type**: `map(string)`
- **Required**: Yes
- **Example**:

  ```hcl
  services = {
    "compute" = "compute.googleapis.com"
    "storage" = "storage.googleapis.com"
  }
  ```

### `disable_dependent_services`

- **Description**: Whether to disable services that are dependent on the service being disabled.
- **Type**: `bool`
- **Default**: `true`
- **Required**: No

## Outputs Detail

### `project_service_id`

- **Description**: The ID of the project service.
- **Type**: `string`
- **Example**:

  ```hcl
  "projects/my-gcp-project/services/compute.googleapis.com"
  ```

## Troubleshooting

- **Insufficient Permissions**: Ensure that the service account or user running Terraform has the `Service Usage Admin` role (`roles/serviceusage.serviceUsageAdmin`) to enable or disable services.
- **Service Availability**: Not all services are available in all regions or projects. Verify the availability of the services you intend to enable.

## Author

- Imam Arief Rahman ([@greyhats13])

---