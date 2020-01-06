# Shared Services architecture: CFT based implementation

## Overview

This folder comtains a CFT based implementation of the [shared services architecture](../README.md) that relies on the [Cloud Foundation Toolkit modules](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit). This implementation is much more compact and streamlined than the [flat implementation](../terraform_flat), and serves as a real world example of how you can leverage the [CFT modules](https://github.com/terraform-google-modules) to simplify your GCP infrastructure deployments.

## Components

The implementation consists in the following elements:

1. `00_projects`: uses CFT's [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) to created the GCP projects for the shared services and the Cloud Native Zone.
2. `01_shared_services`: creates all of the components for the mock shared services project:
    * Network and firewall rules
    * A log sink for autoscaling events and a PubSub topic where proxy autoscale notifications will be received.
    * An instance running an Apache server used for end-to-end helth checks from the CNZ projects.
    * A demo instance running an Apache server behind a network load balancer, mimicking a shared service.
    * A DNS private managed zone where DNS records for the shared services will be added. The CNZ projects will have a peered DNS zone that will expose the services locally.
3. `02_cn_zone`: creates the infrastructure associated to the cloud native zone:
    * Network and firewall rules
    * A managed instance group that creates squid proxy instances as needed to meet demand.
    * An internal load balancer to distribute load among the different proxy instances.
    * A DNS managed zone, peered with the zone defined in the shared services project, where the shared services DNS records are advertised.
    * A sample instance that acts as a mock application. Log into this instance to test the communication with the shared services through the proxy.

## Setup instructions

This implementation uses CFT's project factory module to create the project necessary to run the demo. You will not need to create these projects manually, but will need to run this terraform configuration with a service account that has the following permissions:

 * Permissions required by the project factory module under the folder where the projects will be created ([see](https://github.com/terraform-google-modules/terraform-google-project-factory#permissions))
 * Permissions to create a log sink on the chosen folder ([see](https://github.com/terraform-google-modules/terraform-google-event-function/tree/master/modules/event-folder-log-entry#iam-roles))

The `env_setup.sh` script helps you apply your configuration on the terraform files. Sinply edit the `env_setup.sh` file, replace the placeholders and run the script.

If you managed run the `env_setup.sh` script successfully, most of the configuration is ready. Scan through the files to make sure everything looks correct.

Once the configuration is updated:

1. Apply the terraform configuration from the `00_projects` folder.
2. Apply the terraform configuration from the `01_shared_services` folder.
3. Apply the terraform configuration from the `02_cn_zone` folder.

You should now have a fully functional shared services architecture. 