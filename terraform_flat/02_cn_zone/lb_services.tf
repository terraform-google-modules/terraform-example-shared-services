/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Internal IP address of the TCP load balancer in front of the Squid proxy
resource "google_compute_address" "outbound_proxy" {
  name         = "tcp-lb-ip"
  project      = "${local.project_id}"
  description  = "Internal IP address of the TCP load balancer in front of the Squid proxy"
  address_type = "INTERNAL"
  region       = "${google_compute_subnetwork.service.region}"
  subnetwork   = "${local.subnetwork_svc}"
  address      = "${local.proxy_address}"
}

# Forwarding rule for the internal load balancer that will distribute load among proxy
# instances.
resource "google_compute_forwarding_rule" "outbound_proxy" {
  name                  = "outbound-proxy-fr"
  project               = "${local.project_id}"
  region                = "${google_compute_subnetwork.service.region}"
  load_balancing_scheme = "INTERNAL"
  ip_address            = "${google_compute_address.outbound_proxy.address}"
  network               = "${local.network}"
  subnetwork            = "${local.subnetwork_svc}"
  backend_service       = "${google_compute_region_backend_service.outbound_proxy.self_link}"
  ip_protocol           = "TCP"
  all_ports             = false
  ports                 = ["${var.squid_proxy_port}"]
}

# Load balancer backend: the managed instance group that creates the Squid instances.
resource "google_compute_region_backend_service" "outbound_proxy" {
  name             = "outbound-proxy-backend"
  project          = "${local.project_id}"
  region           = "${google_compute_subnetwork.service.region}"
  session_affinity = "CLIENT_IP"

  backend {
    group = "${google_compute_region_instance_group_manager.outbound_proxy.instance_group}"
  }

  health_checks                   = ["${google_compute_health_check.outbound_proxy.self_link}"]
  connection_draining_timeout_sec = 10
}

# Health check used by the load balancer to determine if backend instances are
# healthy. We use a TCP health check so we can send a proxied HTTP request to the
# healthz shared service. 
resource "google_compute_health_check" "outbound_proxy" {
  name                = "squid-health-check"
  project             = "${local.project_id}"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    request  = <<EOT
GET http://${local.health_service_host}/ HTTP/1.1
Host: ${local.health_service_host}
Cache-Control: no-cache
User-Agent: GoogleHC/1.0
Accept: */*
Proxy-Connection: Keep-Alive

EOT
    response = "HTTP/1.1 200 OK"
    port     = "${var.squid_proxy_port}"
  }
}