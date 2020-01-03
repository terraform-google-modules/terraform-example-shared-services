/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "proxy_autoscale_event" {
  source  = "terraform-google-modules/event-function/google//modules/event-folder-log-entry"
  version = "1.2.0"

  filter     = <<EOF
resource.type="gce_instance_group" AND 
jsonPayload.resource.name="squid-igm" AND
jsonPayload.resource.type="instanceGroup" AND
jsonPayload.event_subtype=("compute.instanceGroups.removeInstances" OR "compute.instanceGroups.addInstances") AND
jsonPayload.event_type="GCE_OPERATION_DONE"
EOF
  name       = "proxy-autoscaler-sink"
  project_id = "${local.project_id}"
  folder_id  = "${local.folder_id}"
}

module "firewall_updater" {
  source  = "terraform-google-modules/event-function/google"
  version = "1.2.0"

  name                  = "fw_updater"
  entry_point           = "fw_updater"
  description           = "Updates ingress firewall rules each time a CNZ proxy instance is added or removed."
  runtime               = "python37"
  region                = "europe-west1"
  project_id            = "${local.project_id}"
  event_trigger         = "${module.proxy_autoscale_event.function_event_trigger}"
  source_directory      = "${path.cwd}/templates/cloud_function"
  service_account_email = "${google_service_account.fw_updater_cf.email}"

  environment_variables = {
    # ID of the Shared Services project, where the fireall rules will be created
    SRV_PROJECT = "${local.project_id}"
    # Network in the Shared Services project where the services instances are located.
    SRV_NETWORK = "${module.svc_network.network_name}"
    # TCP ports to open for ingress connection on the target instances.
    PROXY_PORTS = "${join(",", formatlist("%s", var.proxy_allowed_ports))}"
    # Service accounts take precedence over tags. If you declare the former, the latter
    # will be ignored when creating the firewall rule.
    TARGET_SAS  = "${join(",", formatlist("%s", local.proxy_target_sas))}"
    TARGET_TAGS = "${join(",", formatlist("%s", local.proxy_target_tags))}"
  }
}