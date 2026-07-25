output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the VPC."
  value       = local.azs
}

output "appgateway_subnet_ids" {
  description = "Subnet IDs for the App Gateway / internet-facing ALB tier."
  value       = slice(module.vpc.public_subnets, 0, length(var.appgateway_subnet_cidrs))
}

output "web_subnet_ids" {
  description = "Subnet IDs for the public web tier."
  value       = slice(module.vpc.public_subnets, length(var.appgateway_subnet_cidrs), length(local.public_subnet_cidrs))
}

output "app_subnet_ids" {
  description = "Subnet IDs for the private application tier."
  value       = module.vpc.private_subnets
}

output "database_subnet_ids" {
  description = "Subnet IDs for the database tier."
  value       = module.vpc.database_subnets
}

output "bastion_subnet_ids" {
  description = "Subnet IDs for the bastion / management tier."
  value       = module.vpc.intra_subnets
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group."
  value       = module.vpc.database_subnet_group_name
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways."
  value       = module.vpc.natgw_ids
}

output "public_subnet_ids" {
  description = "All public subnet IDs (app gateway + web)."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private application subnet IDs."
  value       = module.vpc.private_subnets
}
