/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
locals {
  project_id          = "${data.terraform_remote_state.projects.outputs.application_project}"
  network_link        = "${module.cnz_network.network_self_link}"
  subnetwork_link_app = "${module.cnz_network.subnets_self_links[0]}"
  subnetwork_link_svc = "${module.cnz_network.subnets_self_links[1]}"
  network_name        = "${module.cnz_network.network_name}"
  subnetwork_name_app = "${module.cnz_network.subnets_names[0]}"
  subnetwork_name_svc = "${module.cnz_network.subnets_names[1]}"
  svc_project_id      = "${data.terraform_remote_state.shared_services.outputs.shared_services_project}"
  svc_network         = "${data.terraform_remote_state.shared_services.outputs.service_network}"
  proxy_address       = "${data.terraform_remote_state.shared_services.outputs.proxy_address}"
  fw_updater_sa       = "${data.terraform_remote_state.shared_services.outputs.fw_updater_sa}"
  suffix              = "${var.random_suffix == "false" ? "" : "_${random_id.this.hex}"}"
  suffix_dash         = "${var.random_suffix == "false" ? "" : "-${random_id.this.hex}"}"
  dns_services_domain = "${data.terraform_remote_state.shared_services.outputs.dns_services_domain}"
  health_service_host = "${data.terraform_remote_state.shared_services.outputs.health_service_host}"

  # Connections to internal DNS domains will always bypass the proxy
  squid_no_proxy_default = [
    ".${local.project_id}.internal",
    ".google.internal",
    "localhost",
    "127.0.0.1",
  ]
  squid_no_proxy = join(",", concat(local.squid_no_proxy_default, var.squid_no_proxy))

  # List of domains that will be made available via the proxy.
  # By default the shared services domain will be allowed.
  squid_whitelist_default = [
    ".${local.dns_services_domain}",
  ]
  squid_whitelist = join("\n", concat(local.squid_whitelist_default, var.squid_whitelist))
}

# if enabled in the config parameters, this random suffix will be added to resources that
# cannot be deleted and reused with the same name right away. Some resources, like projects,
# GCS buckets and KMS keys are deleted only after a grece period. For test purposes, this
# random suffix can be useful.
resource "random_id" "this" {
  byte_length = 2
}