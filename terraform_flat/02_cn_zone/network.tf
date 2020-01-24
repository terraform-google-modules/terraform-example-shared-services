/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
resource "google_compute_network" "cnz_network" {
  project                 = "${local.project_id}"
  name                    = "cnz-network"
  auto_create_subnetworks = "false"
}

# Subnetwork dedicated to proxy instances that will allow applications to access
# the shared services.
resource "google_compute_subnetwork" "service" {
  project                  = "${local.project_id}"
  ip_cidr_range            = "172.20.20.0/24"
  name                     = "service-zone"
  network                  = "${google_compute_network.cnz_network.name}"
  region                   = "${var.region}"
  private_ip_google_access = true
  log_config {
  }
}

# Subnet where application instances will be deployed.
resource "google_compute_subnetwork" "application" {
  project                  = "${local.project_id}"
  ip_cidr_range            = "172.20.21.0/24"
  name                     = "app-zone"
  network                  = "${google_compute_network.cnz_network.name}"
  region                   = "${var.region}"
  private_ip_google_access = true
  log_config {
  }
}
