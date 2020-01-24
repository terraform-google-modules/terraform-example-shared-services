/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
resource "google_cloudfunctions_function" "fw_updater" {
  project     = "${local.project_id}"
  name        = "fw_updater"
  entry_point = "fw_updater"
  description = "Updates ingress firewall rules each time a CNZ proxy instance is added or removed."
  runtime     = "python37"
  region      = "europe-west1"

  service_account_email = "${google_service_account.fw_updater_cf.email}"
  source_archive_bucket = "${google_storage_bucket.cloud_function.name}"
  source_archive_object = "${google_storage_bucket_object.cloud_function.name}"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "projects/${local.project_id}/topics/${google_pubsub_topic.proxy_updates.name}"
  }

  environment_variables = {
    # ID of the Shared Services project, where the fireall rules will be created
    SRV_PROJECT = "${local.project_id}"
    # Network in the Shared Services project where the services instances are located.
    SRV_NETWORK = "${google_compute_network.svc_network.name}"
    # TCP ports to open for ingress connection on the target instances.
    PROXY_PORTS = "${join(",", formatlist("%s", var.proxy_allowed_ports))}"
    # Service accounts take precedence over tags. If you declare the former, the latter
    # will be ignored when creating the firewall rule.
    TARGET_SAS  = "${join(",", formatlist("%s", local.proxy_target_sas))}"
    TARGET_TAGS = "${join(",", formatlist("%s", local.proxy_target_tags))}"
  }
}

# Push the zip file containing the cloud function to the bucket
resource "google_storage_bucket_object" "cloud_function" {
  name   = "fw_updater.zip"
  source = "${data.archive_file.cloud_function.output_path}"
  bucket = "${google_storage_bucket.cloud_function.name}"
}

# GCS bucket to store the clouf function code
resource "google_storage_bucket" "cloud_function" {
  name               = "${local.project_id}-cf${local.suffix_dash}"
  project            = "${local.project_id}"
  location           = "${var.region}"
  bucket_policy_only = true
  force_destroy      = true
  storage_class      = "REGIONAL"
}

# Create a ZIP file with the cloud function. This file will be uploaded to a 
# GCS bucket, so it can be published as a Cloud function.
data "archive_file" "cloud_function" {
  type        = "zip"
  output_path = "templates/cloud_function.zip"
  source_dir  = "templates/cloud_function"
}
