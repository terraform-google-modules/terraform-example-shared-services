/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "managed_instance_group" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "1.3.0"

  project_id        = "${local.project_id}"
  region            = "${var.region}"
  target_size       = 2
  hostname          = "mig-simple"
  instance_template = "${module.instance_template_sample.self_link}"

  target_pools = [
    "${module.load_balancer_default.target_pool}",
  ]

  named_ports = [{
    name = "http"
    port = 80
  }]
}

module "load_balancer_default" {
  source  = "GoogleCloudPlatform/lb/google"
  version = "2.2.0"

  project      = "${local.project_id}"
  name         = "tcp-lb-example-ip"
  region       = "${var.region}"
  service_port = 80
  network      = "${local.network_link}"
  ip_address   = "${google_compute_address.tcp_lb_example.address}"
}

# This is our (reserved) external IP address used for the example service TCP LB.
# CAUTION: if you destroy this terraform resource, the IP address will be released.
resource "google_compute_address" "tcp_lb_example" {
  name        = "tcp-lb-example-ip"
  project     = "${local.project_id}"
  description = "External IP address of the TCP load balancer that exposes the service"
  region      = "${var.region}"
}

module "instance_template_sample" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "1.3.0"

  project_id     = "${local.project_id}"
  subnetwork     = "${local.subnetwork_link}"
  startup_script = "${data.template_file.instance_startup_script.rendered}"

  service_account = {
    email  = "${google_service_account.shared_service.email}"
    scopes = ["cloud-platform"]
  }
}

data "template_file" "sample_service_index_page" {
  template = "${file("templates/apache/index.html")}"
  vars = {
    service_id = "Sample Service"
  }
}

data "template_file" "instance_startup_script" {
  template = "${file("templates/apache/startup_script.sh.tpl")}"
  vars = {
    index_page = "${data.template_file.sample_service_index_page.rendered}"
  }
}