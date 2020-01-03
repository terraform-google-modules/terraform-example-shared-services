/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
module "shared_services_project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "6.1.0"
  project_id        = "${var.shared_services_project}"
  name              = "Shared services"
  folder_id         = "${var.folder_id}"
  org_id            = "${var.gcp_org_id}"
  billing_account   = "${var.gcp_billing_id}"
  activate_apis     = "${var.project_services}"
  random_project_id = "${var.random_suffix}"
}

module "application_project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "6.1.0"
  project_id        = "${var.application_project}"
  name              = "CNZ application"
  folder_id         = "${var.folder_id}"
  org_id            = "${var.gcp_org_id}"
  billing_account   = "${var.gcp_billing_id}"
  activate_apis     = "${var.project_services}"
  random_project_id = "${var.random_suffix}"
}