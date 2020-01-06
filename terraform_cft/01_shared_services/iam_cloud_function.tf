/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# These are the permissions required by the firewall rule updater cloud function.
# We create a custom role with just the minimum required permissions.
resource "google_project_iam_custom_role" "fw_rule_updater" {
  project     = "${local.project_id}"
  role_id     = "srvFwRuleUpdater"
  title       = "CNZ firewall rule updater"
  description = "permissions required by the CNZ firewall rule updater cloud function to create or update firewall rules for CNZ proxies."
  permissions = [
    "compute.firewalls.get",
    "compute.firewalls.create",
    "compute.firewalls.update",
    "compute.networks.updatePolicy",
  ]
}

# Attach the role to the service account used by the firewall rule updater 
# Cloud Function.
resource "google_project_iam_member" "fw_rule_updater" {
  project = "${local.project_id}"
  role    = "${google_project_iam_custom_role.fw_rule_updater.id}"
  member  = "serviceAccount:${google_service_account.fw_updater_cf.email}"
}