/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */
variable "region" {
  description = "Region to build infrastructure"
  default     = "europe-west4"
}

variable "zone" {
  description = "The availability zone where resources will be placed"
  default     = "europe-west4-a"
}

variable "iap_tunnel_users" {
  description = "List of users with access to the instances via IAP."
  type        = "list"
  default     = []
}

variable "squid_proxy_port" {
  description = "Port on which the Squid proxy will listen."
  default     = "3128"
}

# By default, allow the proxy to reach any IP address. It we need to restrict
# this further, use this variable to add the allowed CIDR ranges. Use this in
# combination with the squid_whitelist variable.
variable "proxy_allowed_dst_ranges" {
  description = "List of IP ranges allowed from the proxy."
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "squid_no_proxy" {
  description = "Domains (in addition to internal domains) for which the proxy will be bypassed."
  type        = "list"
  default     = []
}

variable "squid_whitelist" {
  description = "List of domains (in addition to the shared services domain) that will be whitelisted for outbound connections through the proxy."
  type        = "list"
  default     = []
}

variable "random_suffix" {
  description = "Add a random suffix to some resources to make it simpler to run tests."
  default = true
}

variable "gcp_credentials_path" {
  description = "Path to the json key of the service account used to run this configuration."
}
