/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Logs sink that sends messages to a Pub/Sub topic when proxy instances are added
# to or removed from the managed instance group.
resource "google_logging_project_sink" "autoscaler" {
  name    = "autoscaler-sink"
  project = "${local.project_id}"

  # Sends the messages to a Pub/Sub topic in the shared services project.
  destination = "pubsub.googleapis.com/projects/${local.svc_project_id}/topics/proxy-updates"

  # Filter the proxy MIG scaling logs
  filter = <<EOT
resource.type="gce_instance_group" AND 
jsonPayload.resource.name="${google_compute_region_instance_group_manager.outbound_proxy.name}" AND
jsonPayload.resource.type="instanceGroup" AND
jsonPayload.event_subtype=("compute.instanceGroups.removeInstances" OR "compute.instanceGroups.addInstances") AND
jsonPayload.event_type="GCE_OPERATION_DONE"
EOT

  # Use a unique writer, which creates a unique service account used for writing.
  # This service account will need to be added directly or indirectly (via a user
  # group) to the proxy_notifiers variable.
  unique_writer_identity = true
}
