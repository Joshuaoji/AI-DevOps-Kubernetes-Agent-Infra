resource "aws_security_group" "this" {
  name_prefix = "${var.name}-redis-"
  description = "Security group for ${var.name} Redis cluster."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-redis-sg"
  })
}

resource "aws_security_group_rule" "ingress_from_clients" {
  for_each = toset(var.allowed_security_group_ids)

  type                     = "ingress"
  description              = "Redis access from allowed security groups."
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = each.value
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-redis-subnet-group"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.name
  description          = "Redis cache for ${var.name}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = 6379
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.this.id]

  automatic_failover_enabled = var.num_cache_clusters > 1
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = merge(var.tags, {
    Name = var.name
  })
}
