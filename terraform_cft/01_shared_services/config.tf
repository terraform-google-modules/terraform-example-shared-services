/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
provider "google" {
  version     = "~> 2.16"
  credentials = "${file(var.gcp_credentials_path)}"
  # work around for issue: 
  # https://github.com/terraform-google-modules/terraform-google-vm/issues/60
  project = "${local.project_id}"
  # work around for issue: 
  # https://github.com/terraform-google-modules/terraform-google-vm/issues/61
  region = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "MY_GCS_BUCKET"
    prefix = "TF_STATE_PREFIX/services"
  }
}

data "terraform_remote_state" "projects" {
  backend = "gcs"

  config = {
    bucket = "MY_GCS_BUCKET"
    prefix = "TF_STATE_PREFIX/projects"
  }
}
