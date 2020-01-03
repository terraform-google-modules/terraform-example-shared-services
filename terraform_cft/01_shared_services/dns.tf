/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "cloud-dns" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "3.0.0"

  project_id = "${local.project_id}"
  name       = "${var.dns_services_subdomain}"
  domain     = "${var.dns_services_subdomain}.${var.dns_main_domain}."
  type       = "private"

  private_visibility_config_networks = [
    "${local.network_link}"
  ]

  recordsets = [
    {
      name    = "proxy.${var.dns_services_subdomain}"
      type    = "A"
      ttl     = 300
      records = ["${var.proxy_address}"]
    },
    {
      name    = "healthz.${var.dns_services_subdomain}"
      type    = "A"
      ttl     = 300
      records = ["${google_compute_address.healthz.address}"]
    },
    {
      name    = "example.${var.dns_services_subdomain}"
      type    = "A"
      ttl     = 300
      records = ["${google_compute_address.tcp_lb_example.address}"]
    },
  ]
}