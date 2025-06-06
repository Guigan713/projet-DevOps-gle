resource "google_dns_managed_zone" "my_zone" {
    # replace(var.domain_name, ".", "-") : Remplace les points par des tirets
    name = "${replace(var.domain_name, ".", "-")}-zone"
    dns_name = "${var.domain_name}."
    description = "Zone DNS pour ${var.domain_name}"

    project = var.project
}

resource "google_dns_record_set" "a_record" {
    name = "${var.domain_name}."
    managed_zone = google_dns_managed_zone.my_zone.name
    type = "A"
    ttl = 300
    rrdatas = [var.reverse_proxy_ip]
}

resource "google_dns_record_set" "www_record" {
  name         = "www.${var.domain_name}."
  managed_zone = google_dns_managed_zone.my_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.reverse_proxy_ip]
}