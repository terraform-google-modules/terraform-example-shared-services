/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
resource "gsuite_group" "proxy_notifiers" {
  name        = "${split("@", var.notifiers_group)[0]}"
  email       = "${var.notifiers_group}"
  description = "Service accounts that send autoscaling notifications"
}
