/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Create a private DNS zone that will allow us to reach instances using the subdomain
# of our choice. This will make simpler the HTTPS certificate configuration for internal
# communications.
resource "google_dns_managed_zone" "services" {
  project    = "${local.project_id}"
  name       = "${var.dns_services_subdomain}"
  dns_name   = "${var.dns_services_subdomain}.${var.dns_main_domain}."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = "${local.network}"
    }
  }
}

# Add a DNS record for the proxy
resource "google_dns_record_set" "outbound_proxy" {
  project      = "${local.project_id}"
  name         = "proxy.${google_dns_managed_zone.services.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.services.name}"
  # This IP has been reserved for the proxy in the application's services subnet
  rrdatas = ["${var.proxy_address}"]
}

# Add a DNS record for every service exposed by the shared services project through
# the svc_catalog local var.
resource "google_dns_record_set" "service_catalog" {
  count        = "${length(local.svc_catalog)}"
  project      = "${local.project_id}"
  name         = "${sort(keys(local.svc_catalog))[count.index]}.${google_dns_managed_zone.services.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.services.name}"
  rrdatas      = ["${local.svc_catalog[sort(keys(local.svc_catalog))[count.index]]}"]
}