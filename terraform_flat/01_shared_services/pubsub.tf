/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Create the Pub/Sub topic where the manage instance group update notifications
# will be sent.
resource "google_pubsub_topic" "proxy_updates" {
  project = "${local.project_id}"
  name    = "proxy-updates"
}

# Allow publishing rights to the list of members defined in the proxy_notifiers list.
# In our example, we greate a user group in Cloud Identity and add the application's
# log sink service accounts as they are known.
resource "google_pubsub_topic_iam_member" "proxy_notifiers" {
  count   = "${length(var.proxy_notifiers)}"
  project = "${local.project_id}"
  topic   = "${google_pubsub_topic.proxy_updates.name}"
  role    = "roles/pubsub.publisher"
  member  = "${var.proxy_notifiers[count.index]}"
}