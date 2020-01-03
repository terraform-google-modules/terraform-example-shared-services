/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Service account attached to the squid proxy instances
resource "google_service_account" "squid_proxy" {
  project    = "${local.project_id}"
  account_id = "squid-proxy"
}

# Service account attached to the demo application instance
resource "google_service_account" "application_sa" {
  project    = "${local.project_id}"
  account_id = "application-sa"
}