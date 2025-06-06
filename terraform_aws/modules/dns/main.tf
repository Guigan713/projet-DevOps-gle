# Zone DNS hébergée sur AWS Route 53
resource "aws_route53_zone" "my_zone" {
  name    = var.domain_name
  comment = "Zone DNS pour ${var.domain_name}"

  tags = {
    Name        = "${replace(var.domain_name, ".", "-")}-zone"
  }
}

# Enregistrement A pour le domaine racine
resource "aws_route53_record" "a_record" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [var.reverse_proxy_ip]
}

# Enregistrement A pour le sous-domaine www
resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.reverse_proxy_ip]
}