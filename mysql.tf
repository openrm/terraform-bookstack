# SQL instance

resource "google_sql_database_instance" "mysql" {
  # The -## is because you cannot use the same name of
  # a deleted database until one week after its deletion
  name             = "bookstack-00"
  database_version = "MYSQL_8_0"
  region           = var.gcp.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.default.id
    }
  }
}


# Private connection for SQL instance

resource "google_compute_global_address" "private_ip_address" {
  name          = "bookstack-sql-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.default.name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


# Database

resource "google_sql_database" "database" {
  name     = var.database
  instance = google_sql_database_instance.mysql.name
}


# SQL User

resource "google_sql_user" "bookstack" {
  instance = google_sql_database_instance.mysql.name
  name     = random_string.bookstack_sql_user_name.result
  password = random_password.bookstack_sql_user_password.result
}

resource "random_string" "bookstack_sql_user_name" {
  length  = 12
  special = false
}

resource "random_password" "bookstack_sql_user_password" {
  length  = 16
  special = true
}
