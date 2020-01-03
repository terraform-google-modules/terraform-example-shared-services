/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Create a private DNS zone that will allow us to reach instances exposed by
# the shared service. DNS records are managed in the shared service and peered
# to this DNS zone.
resource "google_dns_managed_zone" "services" {
  provider   = "google-beta" # peering config requires beta provider
  project    = "${local.project_id}"
  name       = "services"
  dns_name   = "${local.dns_services_domain}."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = "${local.network}"
    }
  }
  peering_config {
    target_network {
      network_url = "${local.svc_network}"
    }
  }
}