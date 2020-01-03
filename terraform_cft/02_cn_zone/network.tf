/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "cnz_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.0.1"

  project_id   = "${local.project_id}"
  network_name = "cnz-network"

  subnets = [
    {
      subnet_name           = "service-zone"
      subnet_ip             = "172.20.20.0/24"
      subnet_region         = "${var.region}"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
    {
      subnet_name           = "app-zone"
      subnet_ip             = "172.20.21.0/24"
      subnet_region         = "${var.region}"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    },
  ]
}