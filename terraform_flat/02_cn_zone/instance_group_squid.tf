/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Managed instance group for autoscaling proxy instances to meet demand.
resource "google_compute_region_instance_group_manager" "outbound_proxy" {
  name               = "squid-igm"
  project            = "${local.project_id}"
  base_instance_name = "outbound-proxy"
  version {
    name              = "outbound-proxy"
    instance_template = "${google_compute_instance_template.outbound_proxy.self_link}"
  }
  region = "${var.region}"
}

# Simple autoscaler configuration based on CPU usage.
resource "google_compute_region_autoscaler" "outbound_proxy" {
  name    = "outbound-proxy-autoscaler"
  project = "${local.project_id}"
  region  = "${var.region}"
  target  = "${google_compute_region_instance_group_manager.outbound_proxy.self_link}"

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 3
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

# Template for creating Squid proxy instances in the managed instance group.
resource "google_compute_instance_template" "outbound_proxy" {
  name        = "squid-template"
  project     = "${local.project_id}"
  description = "Squid instance template."

  instance_description = "Squid instance"
  # Consider using larger instances for production
  machine_type            = "n1-standard-1"
  can_ip_forward          = false
  metadata_startup_script = "${data.template_file.startup_script.rendered}"

  disk {
    source_image = "centos-cloud/centos-8"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = "${local.subnetwork_svc}"
    # enable external IP address
    access_config {
      # using default values
    }
  }

  service_account {
    email  = "${google_service_account.squid_proxy.email}"
    scopes = ["cloud-platform"]
  }
}

data "template_file" "squid_config" {
  template = "${file("templates/squid/squid.conf")}"
  vars = {
    squid_proxy_port    = "${var.squid_proxy_port}"
    health_service_host = "${local.health_service_host}"
  }
}

data "template_file" "squid_whitelist" {
  template = "${file("templates/squid/whitelist.txt")}"
  vars = {
    squid_whitelist = "${local.squid_whitelist}"
  }
}

data "template_file" "startup_script" {
  template = "${file("templates/squid/startup_script.sh.tpl")}"
  vars = {
    squid_conf    = "${data.template_file.squid_config.rendered}"
    whitelist_txt = "${data.template_file.squid_whitelist.rendered}"
  }
}
