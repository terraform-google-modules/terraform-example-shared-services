/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# We'll attach this service account to all the instances exposed as services to
# the applications. The common.tf file adds this service account to the list of
# SAs that will be added to the firewall rules created automatically by the cloud
# function.
resource "google_service_account" "shared_service" {
  project      = "${local.project_id}"
  account_id   = "shared-service"
  display_name = "Shared Services"
}

# Service account attached to the cloud function that updates the firewall rules.
# We'll need to grant this SA certain permissions on the shared services project
# and on the application projects.
resource "google_service_account" "fw_updater_cf" {
  project      = "${local.project_id}"
  account_id   = "fw-updater-cf"
  display_name = "Firewall updater Cloud Function"
}
