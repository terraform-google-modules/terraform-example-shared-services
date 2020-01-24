/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
output "shared_services_project" {
  value = "${module.shared_services_project.project_id}"
}

output "application_project" {
  value = "${module.application_project.project_id}"
}

output "folder_id" {
  value = "${var.folder_id}"
}
