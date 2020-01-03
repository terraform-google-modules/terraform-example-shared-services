/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "dns-peering-zone" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "3.0.0"

  project_id                         = "${local.project_id}"
  type                               = "peering"
  name                               = "services"
  domain                             = "${local.dns_services_domain}."
  private_visibility_config_networks = ["${local.network_link}"]
  target_network                     = "${local.svc_network}"
}