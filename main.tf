terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.18.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
    }

  }
}

provider "google" {
  project = var.gcp.project_id
  region  = var.gcp.region
}

provider "cloudflare" {
  api_token = var.cloudflare.api_token
}