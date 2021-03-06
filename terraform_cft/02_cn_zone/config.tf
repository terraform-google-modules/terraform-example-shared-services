/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
provider "google" {
  version     = "~> 2.16"
  credentials = "${file(var.gcp_credentials_path)}"
  project     = "${local.project_id}"
  region      = "${var.region}"
}

provider "google-beta" {
  version     = "~> 2.15"
  credentials = "${file(var.gcp_credentials_path)}"
  project     = "${local.project_id}"
  region      = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "MY_GCS_BUCKET"
    prefix = "TF_STATE_PREFIX/app-project"
  }
}

data "terraform_remote_state" "shared_services" {
  backend = "gcs"

  config = {
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
