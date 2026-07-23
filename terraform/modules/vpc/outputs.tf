output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = module.vpc.private_subnets
}

output "database_subnet_ids" {
  description = "IDs of database subnets."
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group."
  value       = module.vpc.database_subnet_group_name
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways."
  value       = module.vpc.natgw_ids
}
