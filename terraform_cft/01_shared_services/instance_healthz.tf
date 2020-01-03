/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# This is our (reserved) external IP address used for the healthz service.
# CAUTION: if you destroy this terraform resource, the IP address will be released.
resource "google_compute_address" "healthz" {
  name        = "healthz-ip"
  project     = "${local.project_id}"
  description = "External IP address for the service that receives health checks"
  region      = "${var.region}"
}

module "compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "1.3.0"

  hostname          = "healthz"
  instance_template = "${module.instance_template_healthz.self_link}"
  subnetwork        = "${local.subnetwork_link}"
}

module "instance_template_healthz" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "1.3.0"

  project_id   = "${local.project_id}"
  machine_type = "g1-small"
  service_account = {
    email  = "${google_service_account.shared_service.email}"
    scopes = ["cloud-platform"]
  }
  access_config = [
    {
      nat_ip       = "${google_compute_address.healthz.address}"
      network_tier = "PREMIUM"
    }
  ]
  startup_script = "${data.template_file.startup_script.rendered}"
  subnetwork     = "${local.subnetwork_link}"
}

data "template_file" "index_page" {
  template = "${file("templates/apache/index.html")}"
  vars = {
    service_id = "Healthz"
  }
}

data "template_file" "startup_script" {
  template = "${file("templates/apache/startup_script.sh.tpl")}"
  vars = {
    index_page = "${data.template_file.index_page.rendered}"
  }
}