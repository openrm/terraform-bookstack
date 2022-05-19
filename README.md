# About
Terraform configuration to deploy BookStack on Google Cloud Platform with Cloudflare as DNS

# Details
BookStack is run in a Docker container on a Google Compute Engine (GCE) instance. This is facilitated by the [Terraform Google Container VM Metadata Module](https://github.com/terraform-google-modules/terraform-google-container-vm) which deploys docker containers on GCE instances within Google's Container Optomized OS and [LinuxServer.io's BookStack container](https://github.com/linuxserver/docker-bookstack).

The instance sits behind an External HTTPS Load Balancer and a domain configured on Cloudflare.

This configuration also provisions a MySQL Cloud SQL database for use with BookStack.

# Getting Started
1. Clone the repository
2. See the Terraform docs on getting started with the [Google Cloud Platform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
3. Create a `terraform.tfvars` file based on the template (`terraform.tfvars.tpl`) provided
4. Apply the configuration