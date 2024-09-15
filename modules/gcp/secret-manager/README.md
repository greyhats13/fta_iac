# Google Secret Manager Module for Google Cloud Platform (GCP)

This Terraform module manages the creation and management of secrets in Google Secret Manager. It allows you to store, manage, and access secrets securely within your GCP environment.

## Features

- **Secret Creation**: Creates one or multiple secrets in Google Secret Manager.
- **Secret Versions**: Adds secret versions with provided secret data.
- **Labels and Annotations**: Applies labels and annotations for better organization and management.
- **User-Managed Replication**: Supports specifying the replication location of secrets.

## Usage

```hcl
module "secret_manager" {
  source = "<path_to_module_directory>"

  region  = "us-central1"
  name    = "my-secret"
  standard = {
    Unit = "my-unit"
    Env  = "production"
    Code = "my-code"
  }

  secret_data = {
    "db_password" = "my_db_password"
    "api_key"     = "my_api_key"
  }
}
```

## Inputs

| Name          | Description                                            | Type          | Default | Required |
|---------------|--------------------------------------------------------|---------------|---------|:--------:|
| `region`      | GCP region where the secrets will be stored.           | `string`      | n/a     |   yes    |
| `name`        | The base name for the secrets.                         | `string`      | n/a     |   yes    |
| `standard`    | A map containing standard naming conventions.          | `map(string)` | n/a     |   yes    |
| `secret_data` | A map of secrets to be stored in Secret Manager. Keys are secret IDs, and values are secret data. | `map` | n/a | yes |

### `standard` Map Details

The `standard` map should include the following keys:

- `Unit`: The unit or department name.
- `Env`: The environment (e.g., `dev`, `staging`, `production`).
- `Code`: A code representing the project or application.

## Outputs

| Name                   | Description                                         |
|------------------------|-----------------------------------------------------|
| `secret_id`            | A map of secret IDs created in Secret Manager.      |
| `secret_version_id`    | A map of secret version IDs associated with secrets.|
| `secret_version_data`  | A map of the secret data (sensitive).               |

**Note**: The `secret_version_data` output is marked as sensitive and will not be displayed in plaintext in Terraform output.

## Example

```hcl
module "secret_manager" {
  source = "./modules/secret_manager"

  region  = "us-central1"
  name    = "app-secrets"
  standard = {
    Unit = "finance"
    Env  = "production"
    Code = "fin-app"
  }

  secret_data = {
    "db_password" = "supersecretpassword"
    "api_key"     = "abcdef1234567890"
    "smtp_pass"   = "smtppassword"
  }
}
```

## Notes

- **Secret Data**: The `secret_data` variable accepts a map where the key is the `secret_id` and the value is the secret content. You can also provide a map with a `plaintext` key if additional attributes are needed.
- **Labels and Annotations**: Labels and annotations are applied to each secret for organizational purposes, using values from the `standard` map and other variables.
- **Replication**: This module uses user-managed replication to specify the location where the secret is stored. Update the `replication` block if you need different replication settings.
- **Sensitive Outputs**: Be cautious with sensitive outputs. Although Terraform masks sensitive output values, ensure that you handle them securely in your code and logs.

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform

## Resources Created

- **google_secret_manager_secret**: Creates secrets in Google Secret Manager.
- **google_secret_manager_secret_version**: Adds secret versions containing the secret data.

## Input Details

### `region`

- **Description**: The GCP region where the secrets will be stored.
- **Type**: `string`
- **Required**: Yes

### `name`

- **Description**: The base name for the secrets.
- **Type**: `string`
- **Required**: Yes

### `standard`

- **Description**: A map containing standard naming conventions for resources.
- **Type**: `map(string)`
- **Required**: Yes
- **Keys**:
  - `Unit`: Unit or department name.
  - `Env`: Environment name.
  - `Code`: Project or application code.

### `secret_data`

- **Description**: A map of secrets to be stored in Secret Manager.
- **Type**: `map`
- **Required**: Yes
- **Example**:
  ```hcl
  secret_data = {
    "db_password" = "my_db_password"
    "api_key"     = "my_api_key"
  }
  ```

## Output Details

### `secret_id`

- **Description**: A map where each key is the secret ID and the value is the resource ID of the secret in Secret Manager.
- **Type**: `map(string)`

### `secret_version_id`

- **Description**: A map where each key is the secret ID and the value is the resource ID of the secret version.
- **Type**: `map(string)`

### `secret_version_data`

- **Description**: A map where each key is the secret ID and the value is the secret data. This output is sensitive.
- **Type**: `map(string)`
- **Sensitive**: Yes

## References

- [Google Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Terraform Google Provider - google_secret_manager_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret)
- [Terraform Google Provider - google_secret_manager_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version)

---