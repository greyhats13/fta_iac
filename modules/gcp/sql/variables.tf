variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet for private IP"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "db_version" {
  description = "Database version"
  type        = string
  default     = "POSTGRES_14"
}

variable "db_region" {
  description = "Region for the Cloud SQL instance"
  type        = string
  default     = null
}

variable "db_tier" {
  description = "Machine type for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "db_storage" {
  description = "Allocated storage for the database in GB"
  type        = number
  default     = 10
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "gke_network_tags" {
  description = "Network tags for GKE nodes to allow access to Cloud SQL"
  type        = list(string)
  default     = []
}

variable "gke_cluster_network" {
  description = "VPC network where GKE cluster is deployed"
  type        = string
}

variable "gke_cluster_subnet" {
  description = "Subnet where GKE cluster nodes are deployed"
  type        = string
}

variable "enable_iam_authentication" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}