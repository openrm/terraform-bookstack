variable "gcp" {
  type = object({
    project_name = string,
    project_id   = string,
    region       = string,
    zone         = string
  })
}

variable "cloudflare" {
  type = object({
    api_token = string,
    zone_id   = string,
  })
}

variable "oauth" {
  type = object({
    google_app_id     = string,
    google_app_secret = string
  })
}

variable "domain" {
  type = string
}

variable "database" {
  type = string
}

variable "healthcheck_network_tag" {
  type = string
}
