/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
provider "google" {
  version     = "~> 2.16"
  credentials = "${file(var.gcp_credentials_path)}"
}

terraform {
  backend "gcs" {
    bucket = "apszaz-tfstate"
    prefix = "shsvc-poc-cft/projects"
  }
}
