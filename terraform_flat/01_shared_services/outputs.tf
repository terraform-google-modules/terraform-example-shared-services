/*
 * Copyright 2019 Google LLC. This software is provided as-is, without warranty
 * or representation for any use or purpose. Your use of it is subject to your 
 * agreement with Google.  
 */

# Required for configuring DNS peering with application projects.
output "service_network" {
  value = "${local.network}"
}

# We'll choose one IP address from the proxy subnet IPO range and use it for the
# internal load balancer. Since this IP address needs to be mapped in the internal
# DNS, the proxy IP address is configured in the shared services project and exposed
# to the application projects so they configure the ILB accordingly.
output "proxy_address" {
  value = "${var.proxy_address}"
}

# We need to export the name of the service account that will be used by the
# firewall updater Cloud Function. The application projects will need to give
# certain permissions to this service account (list instances in an instance
# group) to be able to obtain the IP addresses of the proxy instances.
output "fw_updater_sa" {
  value = "${google_service_account.fw_updater_cf.email}"
}

# The DNS domain where the services will be exposed (ex. example.services.domain.com)
output "dns_services_domain" {
  value = "${var.dns_services_subdomain}.${var.dns_main_domain}"
}

# The host name of the health check service (ex. healthz.services.domain.com)
output "health_service_host" {
  value = "healthz.${var.dns_services_subdomain}.${var.dns_main_domain}"
}

output "shared_services_project" {
  value = "${var.project_id}"
}