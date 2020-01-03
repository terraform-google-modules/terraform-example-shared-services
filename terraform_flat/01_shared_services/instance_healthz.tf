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

resource "google_compute_instance" "healthz" {
  project                 = "${local.project_id}"
  name                    = "healthz"
  description             = "web server used by the proxy load balancers health checks"
  machine_type            = "g1-small"
  zone                    = "${var.zone}"
  metadata_startup_script = "${data.template_file.startup_script.rendered}"

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
    access_config {
      nat_ip = "${google_compute_address.healthz.address}"
    }
  }
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