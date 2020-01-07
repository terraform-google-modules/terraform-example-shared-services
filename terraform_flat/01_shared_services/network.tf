/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

resource "google_compute_network" "svc_network" {
  project                 = "${local.project_id}"
  name                    = "svc-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "service" {
  project                  = "${local.project_id}"
  ip_cidr_range            = "172.20.20.0/24"
  name                     = "service-zone"
  network                  = "${google_compute_network.svc_network.name}"
  region                   = "${var.region}"
  private_ip_google_access = true
  log_config {
  }
}
