/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
resource "google_compute_firewall" "allow_from_all_to_proxy" {
  project     = "${local.project_id}"
  name        = "allow-from-all-to-proxy"
  description = "allow connections to the proxy from all the instances in the network."
  network     = "${local.network}"
  direction   = "INGRESS"
  priority    = "1000"
  target_service_accounts = [
    "${google_service_account.squid_proxy.email}",
  ]
  allow {
    protocol = "tcp"
    ports    = ["${var.squid_proxy_port}"]
  }
}

# If configured in the proxy_allowed_dst_ranges variable, restrict the IP ranges
# to which the proxy can connect. By default it's 0.0.0.0/0
resource "google_compute_firewall" "allow_from_squid_proxy_to_shared_services" {
  project            = "${local.project_id}"
  name               = "allow-from-squid-proxy-to-shared-services"
  description        = "allow HTTP(S) connections from the Squid proxy to shared services."
  network            = "${local.network}"
  direction          = "EGRESS"
  priority           = "1000"
  destination_ranges = "${var.proxy_allowed_dst_ranges}"
  target_service_accounts = [
    "${google_service_account.squid_proxy.email}",
  ]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Get the IP ranges of the Identity Aware Proxy tunnel so we can enable them in
# the firewall rule.
data "google_netblock_ip_ranges" "iap_tunnel" {
  range_type = "iap-forwarders"
}

# We'ss allow SSH connections coming from the Identity Aware Proxy so we are
# able to connect to the instances through their internal IP address.
resource "google_compute_firewall" "allow_ssh_from_iap_to_all" {
  project       = "${local.project_id}"
  name          = "allow-ssh-from-iap-to-all"
  description   = "allow ssh connections to all instances via the Identity Aware Proxy."
  network       = "${local.network}"
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = "${data.google_netblock_ip_ranges.iap_tunnel.cidr_blocks_ipv4}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
