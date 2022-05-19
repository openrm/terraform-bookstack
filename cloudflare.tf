# DNS A record

resource "cloudflare_record" "bookstack" {
  zone_id = var.cloudflare.zone_id
  name    = split(".", var.domain)[0] # The `subdomain` when var.domain is subdomain.domain.com for example
  value   = google_compute_global_forwarding_rule.bookstack.ip_address
  type    = "A"
}