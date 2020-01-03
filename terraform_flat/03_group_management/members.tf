/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
resource "gsuite_group_members" "proxy_notifiers" {
  count       = "${length(var.proxy_notifiers)}"
  group_email = "${gsuite_group.proxy_notifiers.email}"

  member {
    email = "${var.proxy_notifiers[count.index]}"
    role  = "MEMBER"
  }
}