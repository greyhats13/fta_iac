# KMS Module for Google Cloud Platform (GCP)

This Terraform module provisions a Key Management Service (KMS) setup on GCP, including a KMS Key Ring, Crypto Key, and an associated Service Account with appropriate IAM bindings.

## Features

- **Service Account Creation**: Provisions a service account to interact with KMS resources.
- **Key Ring Creation**: Creates a KMS Key Ring in a specified location.
- **Crypto Key Creation**: Sets up a Crypto Key within the Key Ring, with configurable rotation and destruction schedules, purpose, and version template.
- **IAM Binding**: Binds the service account to the Crypto Key with specified roles.

## Usage

```hcl
module "kms" {
  source = "<path_to_module_directory>"

  project_id = "<GCP Project ID>"
  region     = "<GCP Region>"
  name       = "<Resource Name>"

  keyring_location = "<Key Ring Location>"  # e.g., "us-central1"

  cryptokey_rotation_period            = "<Rotation Period>"             # e.g., "100000s"
  cryptokey_destroy_scheduled_duration = "<Destroy Scheduled Duration>"  # e.g., "86400s"
  cryptokey_purpose                    = "<Purpose>"                     # e.g., "ENCRYPT_DECRYPT"

  cryptokey_version_template = {
    algorithm        = "<Algorithm>"          # e.g., "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "<Protection Level>"   # e.g., "SOFTWARE"
  }

  cryptokey_role = "<IAM Role>"  # e.g., "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}
```

## Inputs

| Name                               | Description                                             | Type          | Default | Required |
|------------------------------------|---------------------------------------------------------|---------------|---------|----------|
| `region`                           | The GCP region where resources will be created.         | `string`      | n/a     | yes      |
| `project_id`                       | The GCP project ID where resources will be created.     | `string`      | n/a     | yes      |
| `name`                             | KMS standard name used for naming resources.            | `string`      | n/a     | yes      |
| `keyring_location`                 | The location of the Key Ring.                           | `string`      | n/a     | yes      |
| `cryptokey_rotation_period`        | The rotation period of the Crypto Key.                  | `string`      | n/a     | yes      |
| `cryptokey_destroy_scheduled_duration` | The scheduled duration before destruction of the Crypto Key. | `string` | n/a     | yes      |
| `cryptokey_purpose`                | The purpose of the Crypto Key (e.g., `ENCRYPT_DECRYPT`).| `string`      | n/a     | yes      |
| `cryptokey_version_template`       | The version template of the Crypto Key, including algorithm and protection level. | `map(string)` | n/a | yes |
| `cryptokey_role`                   | The IAM role to assign to the service account for the Crypto Key. | `string` | n/a     | yes      |

## Outputs

| Name                     | Description                                 |
|--------------------------|---------------------------------------------|
| `service_account_id`     | The ID of the service account.              |
| `service_account_email`  | The email of the service account.           |
| `keyring_id`             | The ID of the KMS Key Ring.                 |
| `cryptokey_id`           | The ID of the KMS Crypto Key.               |

---

**Note**: Replace placeholder values (e.g., `<GCP Project ID>`, `<Key Ring Location>`) with your actual configuration details.

## Example

Here is a more concrete example of how to use this module:

```hcl
module "kms" {
  source = "./modules/kms"

  project_id = "my-gcp-project"
  region     = "us-central1"
  name       = "my-kms"

  keyring_location = "us-central1"

  cryptokey_rotation_period            = "86400s"   # Rotate every 24 hours
  cryptokey_destroy_scheduled_duration = "1209600s" # Schedule destruction in 14 days
  cryptokey_purpose                    = "ENCRYPT_DECRYPT"

  cryptokey_version_template = {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }

  cryptokey_role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}
```

## Resources Created

- **Google Service Account**: Used for accessing the KMS Crypto Key.
- **Google KMS Key Ring**: Acts as a container for Crypto Keys.
- **Google KMS Crypto Key**: The key used for encryption and decryption.
- **IAM Binding**: Grants the service account access to the Crypto Key.

## Requirements

- Terraform version >= 0.12
- Google Cloud Provider plugin for Terraform

## Author

- Imam Arief Rahman ([@greyhats13])

---