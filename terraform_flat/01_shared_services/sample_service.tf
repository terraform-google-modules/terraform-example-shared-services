/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# This is an example of a service that will be exposed to application projects via
# the proxy. It will be made available by its name to clients once we add the DNS
# record in the local.svc_catalog map (under common.tf)

# A TCP LB starts with a forwarding rule (EXTERNAL/TCP in this case). This
# forwarding rule links a (reserved or ephemeral) IP address to a target.
resource "google_compute_forwarding_rule" "tcp_lb_example" {
  name        = "tcp-forwarding-rule-example"
  project     = "${local.project_id}"
  region      = "${google_compute_subnetwork.service.region}"
  ip_address  = "${google_compute_address.tcp_lb_example.address}"
  target      = "${google_compute_target_pool.shared_service.self_link}"
  ip_protocol = "TCP"
  all_ports   = false
  port_range  = "80"
}

# This is our (reserved) external IP address used for the example service TCP LB.
# CAUTION: if you destroy this terraform resource, the IP address will be released.
resource "google_compute_address" "tcp_lb_example" {
  name        = "tcp-lb-example-ip"
  project     = "${local.project_id}"
  description = "External IP address of the TCP load balancer that exposes the service"
  region      = "${google_compute_subnetwork.service.region}"
}

# Use a target pool containing the  instance: the web server of the example service
resource "google_compute_target_pool" "shared_service" {
  name             = "tcp-lb2-target-pool"
  project          = "${local.project_id}"
  region           = "${google_compute_subnetwork.service.region}"
  session_affinity = "CLIENT_IP_PROTO"
  instances = [
    "${google_compute_instance.sample_service.self_link}",
  ]
}

resource "google_compute_instance" "sample_service" {
  project                 = "${local.project_id}"
  name                    = "web-server-example"
  description             = "simple web server to simulate a second shared service"
  machine_type            = "g1-small"
  zone                    = "${var.zone}"
  metadata_startup_script = "${data.template_file.sample_service_startup_script.rendered}"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  service_account {
    email  = "${google_service_account.shared_service.email}"
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = "${local.subnetwork}"
    # Enable external IP address to allow software install on startup.
    access_config {
      # using default values
    }
  }
}

data "template_file" "sample_service_index_page" {
  template = "${file("templates/apache/index.html")}"
  vars = {
    service_id = "Sample Service"
  }
}


data "template_file" "sample_service_startup_script" {
  template = "${file("templates/apache/startup_script.sh.tpl")}"
  vars = {
    index_page = "${data.template_file.sample_service_index_page.rendered}"
  }
}