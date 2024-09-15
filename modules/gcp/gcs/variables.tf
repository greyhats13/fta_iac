variable "region" {
  type        = string
  description = "The geographical region of the bucket. See the official docs for valid values: https://cloud.google.com/storage/docs/locations"
}

variable "name" {
  type        = string
  description = "The name of the bucket. Must be globally unique."
}

# Google Cloud Storage Bucket Configuration
variable "force_destroy" {
  type        = bool
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."
}

variable "public_access_prevention" {
  type        = string
  description = "Prevents public access to a bucket. Acceptable values are 'inherited' or 'enforced'."
}
