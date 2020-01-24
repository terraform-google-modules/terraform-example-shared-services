/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Follow the intructions in the G Suite provider's github page to enable
# group management: https://github.com/DeviaVir/terraform-provider-gsuite
provider "gsuite" {
  credentials             = "${file(var.credentials_path)}"
  impersonated_user_email = "myaccount@my-domain.com"
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.group.member"
  ]
}

terraform {
  backend "gcs" {
    bucket = "MY_GCS_BUCKET"
    prefix = "TF_STATE_PREFIX/groups"
  }
}
