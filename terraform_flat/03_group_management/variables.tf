/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
variable "notifiers_group" {
  description = "Name of the group that will be granted the publisher role on the PubSub topic."
}

variable "proxy_notifiers" {
  description = "List of users or service accounts that will be added to the notifiers_group."
  type        = "list"
  default     = []
}

variable "credentials_path" {
  description = "Path to the json key of the service account used to run this configuration."
}
