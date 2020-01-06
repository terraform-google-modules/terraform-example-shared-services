/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
gcp_billing_id          = "YOUR_BILLING_ID"
gcp_org_id              = "YOUR_ORG_ID"
folder_id               = "YOUR_FOLDER_ID"
shared_services_project = "YOUR_PROJECT_ID"
application_project     = "YOUR_PROJECT_ID"
project_services = [
  "compute.googleapis.com",
  "logging.googleapis.com",
  "dns.googleapis.com",
  "pubsub.googleapis.com",
  "iap.googleapis.com",
  "cloudfunctions.googleapis.com",
]
random_suffix        = "true"
gcp_credentials_path = "/path/to/service_account_key.json"
