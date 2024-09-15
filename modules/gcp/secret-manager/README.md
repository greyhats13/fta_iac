# Google Secret Manager Module for Terraform

This Terraform module manages secrets and their versions in Google Cloud Secret Manager. It allows you to create secrets with custom labels and annotations, specify replication settings, and add secret versions with the secret data.

## Features

- **Secret Creation**: Creates a new secret in Google Secret Manager with specified labels and annotations.
- **User-Managed Replication**: Supports user-managed replication by specifying the regions where the secret is replicated.
- **Secret Version Creation**: Adds a new version to the secret with the provided secret data.
- **Custom Labels and Annotations**: Applies custom labels and annotations based on a standard naming convention.

## Usage

```hcl
module "secret_manager" {
  source = "<path_to_module_directory>"

  region      = "us-central1"
  name        = "my-secret-name"
  secret_data = "my-secret-data"

  standard = {
    Unit    = "my-unit"
    Env     = "prod"
    Code    = "my-code"
    Feature = "my-feature"
  }
}
```

## Inputs

| Name          | Description                                                                                                        | Type          | Default | Required |
|---------------|--------------------------------------------------------------------------------------------------------------------|---------------|---------|:--------:|
| `region`      | The GCP region where the secret will be replicated.                                                                | `string`      | n/a     |   yes    |
| `name`        | The name of the secret.                                                                                            | `string`      | n/a     |   yes    |
| `standard`    | A map containing standard naming convention values for resources (e.g., Unit, Env, Code, Feature).                 | `map(string)` | n/a     |   yes    |
| `secret_data` | The secret data in plaintext to be stored in the secret manager. It can be a JSON object or a string.              | `string`      | n/a     |   yes    |

### `standard` Map Keys

The `standard` map should include the following keys:

- `Unit` (string): The unit or department name.
- `Env` (string): The environment (e.g., `dev`, `staging`, `prod`).
- `Code` (string): A code representing the project or application.
- `Feature` (string): The feature name associated with the secret.

## Outputs

| Name                    | Description                                        |
|-------------------------|----------------------------------------------------|
| `secret_id`             | The resource ID of the created secret.             |
| `secret_version_id`     | The resource ID of the created secret version.     |
| `secret_version_data`   | The version number of the secret (marked sensitive). |

## Example

```hcl
module "secret_manager" {
  source = "./modules/secret_manager"

  region      = "us-central1"
  name        = "db-credentials"
  secret_data = jsonencode({
    username = "db-user"
    password = "db-pass"
  })

  standard = {
    Unit    = "fta"
    Env     = "mstr"
    Code    = "gsm"
    Feature = "iac"
  }
}
```

## Notes

- **Secret Data Format**: The `secret_data` can be a plain string or a JSON-encoded string. If you're storing structured data, consider encoding it using `jsonencode`.
- **Labels and Annotations**: Labels and annotations are applied to the secret resource using the values provided in the `standard` map and the `name` variable.
- **Replication**: The module uses user-managed replication to replicate the secret in the specified `region`.
- **Permissions**: Ensure that the Terraform service account has the necessary permissions to create secrets and secret versions in Google Cloud Secret Manager.

## Requirements

- **Terraform** version >= 0.12
- **Google Cloud Provider** plugin for Terraform

## Resources Created

- **google_secret_manager_secret**: The secret resource in Google Secret Manager.
- **google_secret_manager_secret_version**: The secret version resource containing the secret data.

## Input Details

### `region`

- **Description**: The GCP region where the secret will be replicated.
- **Type**: `string`
- **Required**: Yes

### `name`

- **Description**: The name of the secret.
- **Type**: `string`
- **Required**: Yes

### `standard`

- **Description**: A map containing standard naming convention values for resources.
- **Type**: `map(string)`
- **Required**: Yes
- **Keys**:
  - `Unit`: The unit or department name.
  - `Env`: The environment (e.g., `dev`, `staging`, `prod`).
  - `Code`: A code representing the project or application.
  - `Feature`: The feature name associated with the secret.

### `secret_data`

- **Description**: The secret data in plaintext to be stored. It could be a JSON object or a string.
- **Type**: `string`
- **Required**: Yes

## Output Details

### `secret_id`

- **Description**: The resource ID of the created secret.
- **Type**: `string`

### `secret_version_id`

- **Description**: The resource ID of the created secret version.
- **Type**: `string`

### `secret_version_data`

- **Description**: The version number of the secret. This output is marked as sensitive.
- **Type**: `string`

## Troubleshooting

- **Authentication Errors**: Ensure that your Terraform execution environment has the necessary permissions to create and manage secrets in Google Cloud Secret Manager.
- **Invalid Labels or Annotations**: Verify that the values provided in the `standard` map adhere to label and annotation requirements in Google Cloud.
- **Secret Data Size**: Be aware of any size limitations for secret data in Google Secret Manager.

## References

- [Google Cloud Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Terraform Google Provider - google_secret_manager_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret)
- [Terraform Google Provider - google_secret_manager_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version)

---