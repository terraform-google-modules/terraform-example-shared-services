/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
gcp_billing_id          = "0131D6-94FD9F-065EAB"
gcp_org_id              = "116143322321"
folder_id               = "509020581346"
shared_services_project = "shsvc-poc-ssv"
application_project     = "shsvc-poc-app"
project_services = [
  "compute.googleapis.com",
  "logging.googleapis.com",
  "dns.googleapis.com",
  "pubsub.googleapis.com",
  "iap.googleapis.com",
  "cloudfunctions.googleapis.com",
]
random_suffix        = "true"
gcp_credentials_path = "/Users/alpalacios/Workspaces/credentials/tf-vdf-bootstrap.json"
