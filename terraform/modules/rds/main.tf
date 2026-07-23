resource "random_password" "master" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix = "${var.name}-db-credentials-"
  description = "Master credentials for ${var.name} RDS instance."
  kms_key_id  = var.kms_key_arn

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username        = var.master_username
    password        = random_password.master.result
    engine          = var.engine
    host            = aws_db_instance.primary.address
    port            = aws_db_instance.primary.port
    dbname          = var.database_name
    replica_host    = try(aws_db_instance.replica[0].address, null)
  })

  depends_on = [aws_db_instance.primary]
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-rds-"
  description = "Security group for ${var.name} RDS instances."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-rds-sg"
  })
}

resource "aws_security_group_rule" "ingress_from_clients" {
  for_each = toset(var.allowed_security_group_ids)

  type                     = "ingress"
  description              = "Database access from allowed security groups."
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.this.id
  source_security_group_id = each.value
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.name}-"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

resource "aws_db_instance" "primary" {
  identifier = "${var.name}-primary"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name = "${var.name}-primary"
    Role = "primary"
  })
}

resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? 1 : 0

  identifier          = "${var.name}-replica"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = coalesce(var.replica_instance_class, var.instance_class)

  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(var.tags, {
    Name = "${var.name}-replica"
    Role = "read-replica"
  })
}
