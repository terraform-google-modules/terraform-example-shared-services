/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Grant the logs writer role to the Squid proxy imnstance to allow the
# stackdriver agent send the squid logs to stackdriver.
resource "google_project_iam_member" "proxy_log_writer" {
  project = "${local.project_id}"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.squid_proxy.email}"
}
