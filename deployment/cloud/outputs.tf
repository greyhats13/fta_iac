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