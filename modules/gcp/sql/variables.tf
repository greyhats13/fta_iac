# # GCP Settings
# variable "region" {
#   type        = string
#   description = "The GCP region where resources will be created."
# }

# variable "project_id" {
#   type        = string
#   description = "The GCP project ID where resources will be created."
# }

# variable "standard" {
#   type        = map(string)
#   description = "The standard naming convention for the service."
# }

# variable "name" {
#   type        = string
#   description = "The name of the module or resource."
# }

# # Cloud SQL Instance Reference
# variable "cloudsql_instance_name" {
#   type        = string
#   description = "The name of the existing Cloud SQL instance."
# }

# # Database Arguments
# variable "database" {
#   type        = string
#   description = "The name of the database to create."
# }

# variable "database_charset" {
#   type        = string
#   description = "The charset for the database."
#   default     = "UTF8"
# }

# variable "database_collation" {
#   type        = string
#   description = "The collation for the database."
#   default     = "en_US.UTF8"
# }

# # User Arguments
# variable "username" {
#   type        = string
#   description = "The name of the user to create."
#   sensitive   = true
# }

# variable "password" {
#   type        = string
#   description = "The password for the user."
#   sensitive   = true
# }

# variable "host" {
#   type        = string
#   description = "The host from which the user can connect."
#   default     = null
# }
