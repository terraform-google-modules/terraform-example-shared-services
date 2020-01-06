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
  region       = "${var.region}"
  subnetwork   = "${local.subnetwork_link_svc}"
  address      = "${local.proxy_address}"
}

# Internal load balancer that will distribute load among proxy instances.
module "outbound_proxy_ilb" {
  source = "GoogleCloudPlatform/lb-internal/google"
  # FIXME: the current version of this module published under the terraform registry does not
  # support the request parameter in TCP health checks. The health check will not work correctly
  # untill the following PR has been accepted and published in the terraform registry:
  # Pull request: https://github.com/terraform-google-modules/terraform-google-lb-internal/pull/23
  version = "2.0.1" # TODO: update the version number once the above mentioned PR is live

  region      = "${var.region}"
  name        = "outbound-proxy"
  ports       = ["${var.squid_proxy_port}"]
  ip_address  = "${google_compute_address.outbound_proxy.address}"
  network     = "${local.network_name}"
  subnetwork  = "${local.subnetwork_name_svc}"
  source_tags = []
  target_tags = []

  health_check = {
    type                = "tcp"
    check_interval_sec  = 10
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 2
    request             = <<EOT
GET http://${local.health_service_host}/ HTTP/1.1
Host: ${local.health_service_host}
Cache-Control: no-cache
User-Agent: GoogleHC/1.0
Accept: */*
Proxy-Connection: Keep-Alive

EOT
    response            = "HTTP/1.1 200 OK"
    proxy_header        = "NONE"
    port                = "${var.squid_proxy_port}"
    port_name           = "health-check-port"
    request_path        = ""
    host                = ""
  }

  backends = [
    { group = "${module.outbound_proxy_mig.instance_group}", description = "" },
  ]
}
