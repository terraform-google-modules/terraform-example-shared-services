/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
locals {
  project_id = "${var.project_id}"
  network    = "${google_compute_network.svc_network.self_link}"
  subnetwork = "${google_compute_subnetwork.service.self_link}"

  # The elements in this map will be added to the private DNS zone. To enable an
  # additional service, add a new entry to this mapping.
  svc_catalog = {
    healthz = "${google_compute_address.healthz.address}"
    example = "${google_compute_address.tcp_lb_example.address}"
  }

  # Add here any other tags that you would like to add to the fw rule (besides
  # the ones in the params.tf file)
  additional_tags   = []
  proxy_target_tags = "${concat(var.proxy_target_tags, local.additional_tags)}"

  # Add here any other service accounts that you would like to add to the firewall
  # rule (besides the ones in the params.tf file)
  additional_sas = [
    "${google_service_account.shared_service.email}"
  ]
  proxy_target_sas = "${concat(var.proxy_target_sas, local.additional_sas)}"

  suffix      = "${var.random_suffix == "false" ? "" : "_${random_id.this.hex}"}"
  suffix_dash = "${var.random_suffix == "false" ? "" : "-${random_id.this.hex}"}"

}

# If enabled in the config parameters, this random suffix will be added to
# resources that cannot be deleted and recreated with the same name right away.
# Some resources, like projects, GCS buckets and KMS keys are deleted only
# after a grece period. For test purposes, this random suffix can be useful.
resource "random_id" "this" {
  byte_length = 2
}
