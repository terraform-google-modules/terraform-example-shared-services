/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# These are the permissions required by the firewall rule update cloud function.
# We create a custom role with just the minimum required permissions. This role
# and binding could also be added at the organization or folder level to avoid
# the need to create the custom role in every client project.
resource "google_project_iam_custom_role" "fw_rule_updater" {
  project     = "${local.project_id}"
  role_id     = "cnzFwRuleUpdater${local.suffix}"
  title       = "CNZ firewall rule updater"
  description = "sed by the CNZ firewall rule cloud function to create or update firewall rules for CNZ proxies."
  permissions = [
    # needs to get the instances attached to the outbound proxy managed instance group
    "compute.instanceGroups.get",
    # for each proxy instance, needs to get the external IP address
    "compute.instances.get",
  ]
}

# Attach the role to the service account used by the firewall rule updater 
# Cloud Function.
resource "google_project_iam_member" "fw_rule_updater" {
  project = "${local.project_id}"
  role    = "${google_project_iam_custom_role.fw_rule_updater.id}"
  member  = "serviceAccount:${local.fw_updater_sa}"
}