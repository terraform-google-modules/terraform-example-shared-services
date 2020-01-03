/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
locals {
  project_id = "${data.terraform_remote_state.projects.outputs.shared_services_project}"
  folder_id  = "${data.terraform_remote_state.projects.outputs.folder_id}"
  network_link    = "${module.svc_network.network_self_link}"
  subnetwork_link = "${module.svc_network.subnets_self_links[0]}"

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
}