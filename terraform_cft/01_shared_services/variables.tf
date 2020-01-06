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

variable "dns_main_domain" {
  description = "The DNS domain under which the services subdomain will be added."
}

variable "dns_services_subdomain" {
  description = "The DNS subdomain under which the services will be exposed."
  default     = "services"
}

variable "proxy_target_tags" {
  description = "Proxy firewall rules will apply to instances tagged with any of these network tags (unless SAs provided)."
  type        = "list"
  default     = []
}

variable "proxy_target_sas" {
  description = "Proxy firewall rules will apply to instances attached to any of these service accounts."
  type        = "list"
  default     = []
}

variable "proxy_allowed_ports" {
  description = "List of TCP ports that will be allowed by the firewall rules created for the CNZ proxies."
  type        = "list"
  default = [
    "80",
    "8080",
    "443",
  ]
}

variable "proxy_address" {
  description = "IP address reserved for the proxy LB on the applications services subnet."
  default     = "172.20.20.100"
}

variable "random_suffix" {
  description = "Add a random suffix to some resources to make it simpler to run tests."
}

variable "gcp_credentials_path" {
  description = "Path to the json key of the service account used to run this configuration."
}