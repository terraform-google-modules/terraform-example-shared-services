/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# The writer identity associated to the log export needs to be granted write
# access to the destination Pub/Sub topic.
output "log_export_identity" {
  value = "${google_logging_project_sink.autoscaler.writer_identity}"
}
