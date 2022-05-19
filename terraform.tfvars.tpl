# GCP

gcp = {
  project_name = "bookstack"
  project_id   = ""
  region       = ""
  zone         = ""
}


# Cloudflare

cloudflare = {
  # See cloudflare provider docs for details
  api_token = ""
  zone_id = ""
}


# Used to allow Google login for BookStack

oauth = {
  # See https://www.bookstackapp.com/docs/admin/third-party-auth/#google
  google_app_id = ""
  google_app_secret = ""
}


# Domain for BookStack app

domain = "docs.example.com"


# SQL database name

database = "bookstackapp"


# Network tag for health check firewall

healthcheck_network_tag = "allow-health-check"
