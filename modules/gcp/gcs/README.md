
---

# Google Cloud Storage Terraform Module

This module is designed to create and configure Google Cloud Storage buckets in GCP.

## Features

- Set the name of the bucket
- Set the geographical location of the bucket.
- Option to forcefully delete all objects inside the bucket when destroying the bucket.
- Configure public access prevention for the bucket.

## Usage

### Terraform State Storage

```hcl
terraform {
  backend "gcs" {
    bucket  = "<GCS Bucket Name>"
    prefix  = "<GCS Bucket Prefix>"
  }
}

module "gcloud-storage-tfstate" {
  source                   = "../../modules/storage/gcloud-storage"
  name                     = "<GCS Bucket Name>"
  force_destroy            = true
  public_access_prevention = "enforced"
}
```

## Inputs

| Name                      | Description                                                   | Type   | Default | Required |
|---------------------------|---------------------------------------------------------------|--------|---------|----------|
| region                    | The geographical location of the bucket.                      | string | -       | Yes      |
| name                      | The name of the bucket.                                      | string | -       | Yes      |
| force_destroy             | Delete all objects in the bucket when destroying the bucket.  | bool   | false   | No       |
| public_access_prevention  | Public access prevention to the bucket ('inherited' or 'enforced'). | string | "inherited" | No |

## Outputs

| Name             | Description                       |
|------------------|-----------------------------------|
| bucket_name      | The name of the bucket.           |
| bucket_url       | The URL of the bucket.            |
| bucket_self_link | The link to the bucket resource in GCP. |

---