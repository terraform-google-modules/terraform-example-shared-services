# Shared Services architecture

## Overview

This folder comtains a [CFT based implementation](./terraform_cft), that relies on the (Cloud Foundation Toolkit modules)[https://github.com/terraform-google-modules]. This implementation is much more compact and streamlined than the [flat implementation](../terraform_flat), and serves as a real world example of how you can leverage CFT modules to simplify your GCP infrastructure deployments.

## Components

The implementation consists in the following elements:

1. `env_setup.sh`: bash script that creates the necessary projects (shared services andCNZ project), the service account that will be used for applying the terraform configuration and the GCS bucket used as remote state for terraform. It also configures the terraform files to use the newly created resources.
2. `01_shared_services`: creates all of the components for the mock shared services project:
    * Network and firewall rules
    * A PubSub topic where proxy autoscale notifications will be received.
    * An instance running an Apache server used for end-to-end helth checks from the CNZ projects.
    * A demo instance running an Apache server behind a network load balancer, mimicking a shared service.
    * A DNS private managed zone where DNS records for the shared services will be added. The CNZ projects will have a peered DNS zone that will expose the services locally.
3. `02_cn_zone`: creates the infrastructure associated to the cloud native zone:
    * Network and firewall rules
    * A managed instance group that creates squid proxy instances as needed to meet demand.
    * An internal load balancer to distribute load among the different proxy instances.
    * A DNS managed zone, peered with the zone defined in the shared services project, where the shared services DNS records are advertised.
    * A log sink that sends notifications to the shared services PubSub topic whenever a proxy instance is added or removed.
    * A sample instance that acts as a mock application. Log into this instance to test the communication with the shared services through the proxy.
3. `03_group_management`: each time a CNZ is created, a unique service account is generated associated with the log sink of the CNZ. This service account needs to be granted the Publisher role on the shared services topic. To ease the management of the PubSub topic permissions, we have created a group in Cloud Identity. This group has been given the Publisher rights on the topic. The log sink service account of each new CNZ needs to be added to this group. This module helps managing this group with terraform the [open source G Suite terraform provider](https://github.com/DeviaVir/terraform-provider-gsuite).

## Setup instructions

The demo requires the creation of two GCP projects that will act as Shared services project and Cloud Native Zone project. You can use the `env_setup.sh` script, which  creates the necessary resources to apply the terraform config provided in this folder:

* Creates two projects for deploying the demo infrastructure.
* Creates the service account that will be usded to run the tf config
* Assigns the project owner role to the SA in the demo projects
* Creates GCS bucket for the terraform remote state in one of the projects.
* Grants the necessary permissions on the bucket to the service account.
* Updates the terraform configuration files to use the chosen SA and bucket.

To run this script you will need to have the proper permissions to:

*  Create projects on the specified folder.
*  Link projects to a billing account (Billing Account User role).
*  Grant owner permissions on the project just created.

If you managed run the `env_setup.sh` script successfully, most of the configuration is ready. You will only need to make smapp adjustments to the `01_shared_services/params.tfvars` and `02_cn_zone/params.tfvars` files. You will need to at least change the parameters where "@my-domain.com" is found.

Once the configuration is updated:

1. Apply the terraform configuration from the `01_shared_services` folder.
2. Apply the terraform configuration from the `02_cn_zone` folder. Take note of the service account from the `log_export_identity` output.
3. Grant publisher rights to the log export service account on the shared services project by either:
  a. Adding the service account to the `proxy_notifiers` parameter in the shared services project (apply the terraform config again).
  b. If you created a proxy notifiers group in Cloud Identity, add the service account to the group.
4. The Shared service firewall rule will be updated the next time the CNX proxy managed instance group adds or removes an instance. You can manually change the min/max instances in the instance group to provoke this update.

You should now having a fully functional shared services architecture. 