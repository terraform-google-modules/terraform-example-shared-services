/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
project_id = "apszaz-shsvc-app-5af0da"
region     = "europe-west4"
zone       = "europe-west4-c"
# List of users or groups that will be allowed to SSH into the instances of the project.
iap_tunnel_users = [
  "user:alfonso@apszaz.com",
]
squid_no_proxy = [
  ".googleapis.com",
  ".google.com",
  ".googlecloud.com",
]
squid_whitelist = [
  #"whitelist.example.com",
  #".example2.com",
]
random_suffix        = true
gcp_credentials_path = "/Users/alpalacios/Workspaces/credentials/tf-vdf-bootstrap.json"
