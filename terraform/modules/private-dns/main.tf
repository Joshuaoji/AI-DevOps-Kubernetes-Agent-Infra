resource "aws_route53_zone" "this" {
  name = var.name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route53_record" "this" {
  for_each = {
    for record in var.records : record.name => record
  }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = try(each.value.alias, null) == null ? each.value.ttl : null
  records = try(each.value.alias, null) == null ? each.value.records : null

  dynamic "alias" {
    for_each = try(each.value.alias, null) == null ? [] : [each.value.alias]

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}
