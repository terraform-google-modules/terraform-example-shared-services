/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Simple instance to simulate a client application that uses the outbound proxy.
resource "google_compute_instance" "client_app" {
  project      = "${local.project_id}"
  name         = "client-app"
  description  = "dummy instance to use for testing the proxy"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  # Configure the outbound proxy as system default
  metadata_startup_script = <<EOT
cat <<EOF > /etc/environment
http_proxy="http://proxy.${local.dns_services_domain}:${var.squid_proxy_port}"
https_proxy="http://proxy.${local.dns_services_domain}:${var.squid_proxy_port}"
ftp_proxy="http://proxy.${local.dns_services_domain}:${var.squid_proxy_port}"
no_proxy="${local.squid_no_proxy}"
EOF
EOT

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
    auto_delete = true
  }

  service_account {
    email  = "${google_service_account.application_sa.email}"
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = "${local.subnetwork_app}"
  }
}
