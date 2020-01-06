#!/bin/bash -e
###############################################################################
# Copyright 2019 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your 
# agreement with Google.  
###############################################################################
# This script applies the necessary changes to the terraform configuration
# files.
###############################################################################

###############################################################################
# At a minimum you will need to change the following parameters
###############################################################################
# ID of the projects that will be created for the demo
PRJ_SHARED_SERVICES="[YOUR_PROJECT_ID]"
PRJ_APPLICATION="[YOUR_PROJECT_ID]"
# Folder ID where the projects will be created
FOLDER_ID="[YOUR_FOLDER_ID]"
# ID of the GCP organization where the projects will be created
GCP_ORG_ID="116143322321"
# ID of the GCS bucket that will be used for the terraform remote state
TF_STATE_BUCKET="[YOUR_GCS_BUCKET_ID]"
# Prefix for the terraform remote state
TF_STATE_PREFIX="shsvc-poc-cft"
# Billing account to attach to the projects
BILLING_ACCOUNT="[YOUR_BILLING_ID]"
# User that will be granted access to the instances created. You can add more 
# users later by modifying the parameters.tf files. Defaults to current user.
GCLOUD_USER=$(gcloud config list account --format "value(core.account)")
# Domain of your GCP organization. Defaults to the current user's domain.
GCP_DOMAIN=$(echo $GCLOUD_USER | cut -d @ -f 2)
# The path to tha service account's private key to use when running this terraform configuration
SA_PATH='/patth/to/credentials.json'

###############################################################################
# Update configuration files
###############################################################################
echo "applying configuration..."

# Update the terraform config files
export GCLOUD_USER
perl -e 's/myaccount\@my-domain.com/$ENV{"GCLOUD_USER"}/' -pi */params.tfvars
export GCP_DOMAIN
perl -e 's/my-domain.com/$ENV{"GCP_DOMAIN"}/' -pi */params.tfvars
export SA_PATH
perl -e 's/^(\s*gcp_credentials_path\s*=\s*")([^"]+)(".*)$/$1$ENV{"SA_PATH"}$3/' -pi */params.tfvars
export PRJ_SHARED_SERVICES
perl -e 's/^(\s*shared_services_project\s*=\s*")([^"]+)(".*)$/$1$ENV{"PRJ_SHARED_SERVICES"}$3/' -pi 00_projects/params.tfvars
export PRJ_APPLICATION
perl -e 's/^(\s*application_project\s*=\s*")([^"]+)(".*)$/$1$ENV{"PRJ_APPLICATION"}$3/' -pi 00_projects/params.tfvars

# Update the folder ID
export FOLDER_ID
perl -e 's/^(\s*folder_id\s*=\s*")([0-9]+)(".*)$/$1$ENV{"FOLDER_ID"}$3/' -pi */params.tfvars

# Update the GCP organization ID
export GCP_ORG_ID
perl -e 's/^(\s*gcp_org_id\s*=\s*")([0-9]+)(".*)$/$1$ENV{"GCP_ORG_ID"}$3/' -pi */params.tfvars

# Update the bucket name in the config files
export TF_STATE_BUCKET
perl -e 's/^(\s*bucket\s*=\s*")([^"]+)(".*)$/$1$ENV{"TF_STATE_BUCKET"}$3/' -pi */config.tf

# Update the remote state prefix in the config files
export TF_STATE_PREFIX
perl -e 's/^(\s*prefix\s*=\s*")([^"\/]+)(["\/].*)$/$1$ENV{"TF_STATE_PREFIX"}$3/' -pi */config.tf

echo "Done."
