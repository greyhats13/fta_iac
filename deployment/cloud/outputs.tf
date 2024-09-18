# Outputs for the GCS Deployment
output "bucket_name" {
  value       = module.gcs_tfstate.bucket_name
  description = "The name of the created Google Cloud Storage bucket."
}

output "bucket_url" {
  value       = module.gcs_tfstate.bucket_url
  description = "The URL of the created Google Cloud Storage bucket."
}

output "bucket_self_link" {
  value       = module.gcs_tfstate.bucket_self_link
  description = "The self link of the created Google Cloud Storage bucket, useful for referencing the bucket in other resources within the same project."
}

# Outputs for the VPC Deployment

# VPC Outputs
output "main_vpc_id" {
  value       = module.vpc_main.vpc_id
  description = "The unique identifier of the VPC."
}

output "main_vpc_self_link" {
  value       = module.vpc_main.vpc_self_link
  description = "The URI of the VPC in GCP."
}

output "main_vpc_gateway_ipv4" {
  value       = module.vpc_main.vpc_gateway_ipv4
  description = "The IPv4 address of the VPC's default internet gateway."
}

# Subnetwork Outputs
output "main_subnet_self_link" {
  value       = module.vpc_main.subnet_self_link
  description = "The URI of the subnetwork in GCP."
}

output "main_subnet_ip_cidr_range" {
  value       = module.vpc_main.subnet_ip_cidr_range
  description = "The primary IP CIDR range of the subnetwork."
}

output "main_pods_secondary_range_name" {
  value       = module.vpc_main.pods_secondary_range_name
  description = "The name of the secondary IP range for pods."
}

output "main_services_secondary_range_name" {
  value       = module.vpc_main.services_secondary_range_name
  description = "The name of the secondary IP range for services."
}

# Router Outputs
output "main_router_id" {
  value       = module.vpc_main.router_id
  description = "The unique identifier of the router."
}

output "main_router_self_link" {
  value       = module.vpc_main.router_self_link
  description = "The URI of the router in GCP."
}

# NAT Outputs
output "main_nat_id" {
  value       = module.vpc_main.nat_id
  description = "The unique identifier of the NAT."
}

# Firewall Outputs
output "main_firewall_ids" {
  value       = module.vpc_main.firewall_ids
  description = "The unique identifier of the firewall rule"
}

output "main_firewall_self_links" {
  value       = module.vpc_main.firewall_self_links
  description = "The URI of the firewall rule"
}

# Outputs for the KMS Deployment
output "security_keyring_id" {
  value = module.kms_main.keyring_id
}

output "security_cryptokey_id" {
  value = module.kms_main.cryptokey_id
}

output "security_service_account_id" {
  value = module.kms_main.service_account_id
}

output "security_service_account_email" {
  value = module.kms_main.service_account_email
}

# Outputs for the DNS Deployment
# FTA zone
output "main_dns_id" {
  value = module.dns_main.dns_id
}

output "main_dns_zone_name" {
  value = module.dns_main.dns_zone_name
}

output "main_dns_name" {
  value = module.dns_main.dns_name
}

output "main_dns_managed_zone_id" {
  value = module.dns_main.dns_managed_zone_id
}

output "main_dns_name_servers" {
  value = module.dns_main.dns_name_servers
}

output "main_dns_zone_visibility" {
  value = module.dns_main.dns_zone_visibility
}


# Github Outputs

## Repo IAC
output "iac_repo_fullname" {
  value = flatten(module.repo_iac.*.full_name)[0]
}

output "iac_repo_ssh_clone_url" {
  value = flatten(module.repo_iac.*.ssh_clone_url)[0]
}

output "iac_repo_http_clone_url" {
  value = flatten(module.repo_iac.*.http_clone_url)[0]
}

## Repo Gitops
output "gitops_repo_fullname" {
  value = flatten(module.repo_gitops.*.full_name)[0]
}

output "gitops_repo_ssh_clone_url" {
  value = flatten(module.repo_gitops.*.ssh_clone_url)[0]
}

output "gitops_repo_http_clone_url" {
  value = flatten(module.repo_gitops.*.http_clone_url)[0]
}

# Cloud SQL Outputs
output "cloudsql_instance_name" {
  value = module.cloudsql_instance_main.instance_name
}

output "cloudsql_instance_connection_name" {
  value = module.cloudsql_instance_main.instance_connection_name
}

output "cloudsql_instance_self_link" {
  value = module.cloudsql_instance_main.instance_self_link
}
