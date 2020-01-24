/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

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
