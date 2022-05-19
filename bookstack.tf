# Compute engine instance template

resource "google_compute_instance_template" "bookstack" {
  name_prefix  = "bookstack"
  machine_type = "e2-medium"

  # Container Optomized OS with bookstack container
  disk {
    source_image = module.gce-container.source_image
  }

  # Persistent disk to store config, images, etc...
  disk {
    source      = google_compute_disk.bookstack.name
    device_name = google_compute_disk.bookstack.name
    auto_delete = false
    boot        = false
    mode        = "READ_WRITE"
  }

  network_interface {
    network = data.google_compute_network.default.name

    # Without this the container will not start on the instance
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.bookstack.email
    scopes = ["cloud-platform"]
  }

  tags = [var.healthcheck_network_tag]

  lifecycle {
    create_before_destroy = true
  }
}


# BookStack Docker Container

module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"

  container = {
    image = "ghcr.io/linuxserver/bookstack:22.03.1"
    env = [
      {
        name  = "APP_URL"
        value = "https://${var.domain}"
      },
      {
        name  = "DB_HOST"
        value = google_sql_database_instance.mysql.private_ip_address
      },
      {
        name  = "DB_DATABASE"
        value = google_sql_database.database.name
      },
      {
        name  = "DB_USER"
        value = random_string.bookstack_sql_user_name.result
      },
      {
        name  = "DB_PASS"
        value = random_password.bookstack_sql_user_password.result
      },
      {
        name  = "GOOGLE_APP_ID"
        value = var.oauth.google_app_id
      },
      {
        name  = "GOOGLE_APP_SECRET"
        value = var.oauth.google_app_secret
      },
      {
        name  = "GOOGLE_AUTO_REGISTER"
        value = true
      },
      {
        name  = "GOOGLE_AUTO_CONFIRM_EMAIL"
        value = true
      },
      {
        name  = "STORAGE_TYPE"
        value = "local_secure"
      }
    ]

    volumeMounts = [
      {
        mountPath = "/config"
        name      = google_compute_disk.bookstack.name
        readOnly  = false
      },
    ]
  }

  volumes = [
    {
      name = google_compute_disk.bookstack.name

      gcePersistentDisk = {
        pdName = google_compute_disk.bookstack.name
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "Always"
}


# Service account

resource "google_service_account" "bookstack" {
  account_id   = "bookstack"
  display_name = "BookStack Service Account"
}


# IAM role with Compute Disks permissions

resource "google_project_iam_custom_role" "compute-disks" {
  role_id = "compute_disks"
  title   = "Compute disks permissions"
  permissions = [
    # https://github.com/terraform-google-modules/terraform-google-container-vm#configure-a-service-account
    "compute.disks.addResourcePolicies",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.disks.createTagBinding",
    "compute.disks.delete",
    "compute.disks.deleteTagBinding",
    "compute.disks.get",
    "compute.disks.getIamPolicy",
    "compute.disks.list",
    "compute.disks.listTagBindings",
    "compute.disks.removeResourcePolicies",
    "compute.disks.resize",
    "compute.disks.setIamPolicy",
    "compute.disks.setLabels",
    "compute.disks.update",
    "compute.disks.use",
    "compute.disks.useReadOnly",
    "compute.diskTypes.get",
    "compute.diskTypes.list"
  ]
}


# BookStack service account compute disks IAM member

resource "google_project_iam_member" "compute-disks" {
  project = var.gcp.project_id
  role    = google_project_iam_custom_role.compute-disks.id
  member  = "serviceAccount:${google_service_account.bookstack.email}"
}



# Persistent Disk

resource "google_compute_disk" "bookstack" {
  name = "bookstack"
  type = "pd-standard"
  zone = var.gcp.zone
  size = 50 # Gigabytes
  # This disk has been formatted manually (outside of this terraform configuration) as follows:
  # https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
}