# SSL Certificate

resource "google_compute_managed_ssl_certificate" "bookstack" {
  name = "bookstack"

  managed {
    domains = [var.domain]
  }
}


# HTTPS Proxy

resource "google_compute_target_https_proxy" "bookstack" {
  name             = "bookstack"
  url_map          = google_compute_url_map.bookstack.id
  ssl_certificates = [google_compute_managed_ssl_certificate.bookstack.id]
}


# URL Map

resource "google_compute_url_map" "bookstack" {
  name = "bookstack"

  default_service = google_compute_backend_service.bookstack.id

  host_rule {
    hosts        = [var.domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.bookstack.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.bookstack.id
    }
  }
}


# Forwarding Rule

resource "google_compute_global_forwarding_rule" "bookstack" {
  name       = "bookstack"
  target     = google_compute_target_https_proxy.bookstack.id
  port_range = 443
}


# Bakend Service

resource "google_compute_backend_service" "bookstack" {
  name                  = "bookstack"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.load_balancer.id]
  backend {
    group           = google_compute_instance_group_manager.bookstack.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}


# Instance group manager

resource "google_compute_instance_group_manager" "bookstack" {
  name = "bookstack"
  zone = var.gcp.zone

  named_port {
    name = "http"
    port = 80
  }

  version {
    instance_template = google_compute_instance_template.bookstack.id
  }
  base_instance_name = "vm"
  target_size        = 1

  update_policy {
    type           = "PROACTIVE"
    minimal_action = "REPLACE"
  }

  wait_for_instances = true

  lifecycle {
    create_before_destroy = true
  }
}


# Load balancer health check

resource "google_compute_health_check" "load_balancer" {
  name               = "bookstack-load-balancer"
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check {
    port         = google_compute_instance_group_manager.bookstack.named_port.*.port[0]
    request_path = "/login"
  }
}


# Health check firewall

resource "google_compute_firewall" "health_check" {
  name          = "bookstack-load-balancer-health-check"
  provider      = google
  direction     = "INGRESS"
  network       = data.google_compute_network.default.name
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = [var.healthcheck_network_tag]
}