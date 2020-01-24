/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Managed instance group for autoscaling proxy instances to meet demand.
module "outbound_proxy_mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "1.3.0"

  project_id          = "${local.project_id}"
  region              = "${var.region}"
  hostname            = "outbound-proxy"
  instance_template   = "${module.instance_template_squid.self_link}"
  autoscaling_enabled = true
  min_replicas        = 1
  max_replicas        = 3
  autoscaling_cpu = [
    {
      target = 0.7
    }
  ]
  cooldown_period      = 60
  hc_initial_delay_sec = 10
}

# Template for creating Squid proxy instances in the managed instance group.
module "instance_template_squid" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "1.3.0"

  project_id  = "${local.project_id}"
  name_prefix = "squid-proxy"
  # Consider using larger instances for production
  machine_type = "n1-standard-1"
  service_account = {
    email  = "${google_service_account.squid_proxy.email}"
    scopes = ["cloud-platform"]
  }
  # n
  access_config = [
    {
      nat_ip       = null
      network_tier = "PREMIUM"
    }
  ]
  startup_script = "${data.template_file.startup_script.rendered}"
  subnetwork     = "${local.subnetwork_link_svc}"
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
