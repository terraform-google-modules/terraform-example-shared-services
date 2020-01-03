/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Instances do not have external IP addresses. Connections will be made only through
# the Identity Aware Proxy (IAP). The iap.tunnelResourceAccessor role is required
# to be able to open an SSH tunnel to an instance. 
data "google_iam_policy" "iap_tunnel" {
  binding {
    role    = "roles/iap.tunnelResourceAccessor"
    members = "${var.iap_tunnel_users}"
  }
}

# Grant IAP secure tunnel user permission to each one of the instances.
resource "google_iap_tunnel_instance_iam_policy" "client_app" {
  project     = "${local.project_id}"
  provider    = "google-beta"
  instance    = "${google_compute_instance.client_app.name}"
  zone        = "${var.zone}"
  policy_data = "${data.google_iam_policy.iap_tunnel.policy_data}"
}

# In addition to the above permissions, a user needs the serviceAccountUser role on
# the SA attached to the shared service instances.
resource "google_service_account_iam_member" "tunnel_user" {
  count              = "${length(var.iap_tunnel_users)}"
  service_account_id = "${google_service_account.application_sa.name}"
  role               = "roles/iam.serviceAccountUser"
  member             = "${element(var.iap_tunnel_users, count.index)}"
}