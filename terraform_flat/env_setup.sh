#!/bin/bash -e
###############################################################################
# Copyright 2019 Google LLC. This software is provided as-is, without warranty
# or representation for any use or purpose. Your use of it is subject to your 
# agreement with Google.  
###############################################################################
# This script creates the necessary resources to apply the terraform config
# provided in this folder. Namely:
# - Creates two projects for deploying the demo infrastructure.
# - Creates the service account that will be usded to run the tf config
# - Assigns the project owner role to the SA in the demo projects
# - Creates GCS bucket for the terraform remote state in one of the projects.
# - Grants the necessary permissions on the bucket to the service account.
# - Updates the terraform configuration files to use the chosen SA and bucket.
#
# To run this script you will need to have the proper permissions to:
# - Create projects on the specified folder.
# - Link projects to a billing account (Billing Account User role).
# - Grant owner permissions on the project just created.
###############################################################################

###############################################################################
# At a minimum you will need to change the following parameters
###############################################################################
# ID of the projects that will be created for the demo
PRJ_SHARED_SERVICES="[YOUR_PROJECT_ID]"
PRJ_APPLICATION="[YOUR_PROJECT_ID]"
# Folder ID where the projects will be created
FOLDER_ID="[YOUR_FOLDER_ID]"
# ID of the GCS bucket that will be used for the terraform remote state
TF_STATE_BUCKET="[YOUR_GCS_BUCKET_ID]"
# Billing account to attach to the projects
BILLING_ACCOUNT="[YOUR_BILLING_ID]"
# User that will be granted access to the instances created. You can add more 
# users later by modifying the parameters.tf files. Defaults to current user.
GCLOUD_USER=$(gcloud config list account --format "value(core.account)")
# Domain of your GCP organization. Defaults to the current user's domain.
GCP_DOMAIN=$(echo $GCLOUD_USER | cut -d @ -f 2)
# User group where the log sink service accounts will be added. You will need
# to create this group in Cloud Identity. Defaults to proxy-notifiers@domain.com
NOTIFIERS_GROUP="proxy-notifiers@${GCP_DOMAIN}"

###############################################################################
# Optionally, change the following parameters
###############################################################################
# Optional: add a random suffix to the project and bucket IDs. Comment out if
# not needed.
RANDOM_SUFFIX=$(hexdump -n 3 -e '4/4 "%04X" 1 "\n"' /dev/random | tr '[:upper:]' '[:lower:]' | xargs)
# Overrite the random suffix if provided in connand line
if [ "$#" == "1" ]; then
  RANDOM_SUFFIX="$1"
fi
TF_STATE_BUCKET="${TF_STATE_BUCKET}-${RANDOM_SUFFIX}"
PRJ_SHARED_SERVICES="${PRJ_SHARED_SERVICES}-${RANDOM_SUFFIX}"
PRJ_APPLICATION="${PRJ_APPLICATION}-${RANDOM_SUFFIX}"
# Project where the terraform service account will be created. Use the shared
# services project by default. modify if needed.
SA_PROJECT=${PRJ_SHARED_SERVICES}
# Neme of the service account that will be created for running the terraform code
SA_NAME="shared-services-tf"
# Project where the GCS bucket for the terraform remote state will be located
BUCKET_PROJECT_ID=$SA_PROJECT
BUCKET_REGION="EUROPE-WEST1"
# Prefix for the terraform remote state
TF_STATE_PREFIX="shared-services"
# Path where the SA credentials file will be stored
SA_PATH="$(pwd)/credentials/${SA_NAME}.json"
# GCP services to enable in the projects
GCP_SERVICES="compute.googleapis.com \
              iam.googleapis.com \
              cloudresourcemanager.googleapis.com \
              logging.googleapis.com \
              dns.googleapis.com \
              pubsub.googleapis.com \
              iap.googleapis.com \
              cloudfunctions.googleapis.com"

# Create the projects for the demo
for project in $PRJ_SHARED_SERVICES $PRJ_APPLICATION; do
  # create the project and enable billing
  echo "Creating project $project"

  # Create the project if it does not already exist
  ((gcloud projects describe $project 2>&1) > /dev/null && \
        echo "Project already exists") || \
  (gcloud projects create $project --folder=$FOLDER_ID && \
   gcloud beta billing projects link $project --billing-account=$BILLING_ACCOUNT)

  # Enable the required GCP services
  echo "Enabling services on project $project"
  gcloud services enable $GCP_SERVICES --project=$project
done

# Create the service account, if it does not already exist. This service account
# will be used for running the terraform configuration
SA_EMAIL="${SA_NAME}@${SA_PROJECT}.iam.gserviceaccount.com"
((gcloud iam service-accounts describe $SA_EMAIL --project="$SA_PROJECT" 2>&1) > /dev/null && \
        echo "service account $SA_NAME already exists in project $SA_PROJECT") || \
  (echo "Creating service account $SA_NAME in project $SA_PROJECT" ; gcloud iam service-accounts create $SA_NAME \
       --description="Terraform SA for the shared services demo" --project=$SA_PROJECT)

# Create and doenload a private key for the service account
echo "Generating service account private key"
mkdir -p $(dirname ${SA_PATH})
gcloud iam service-accounts keys create ${SA_PATH} --iam-account=${SA_EMAIL}

# Grant the project owner role to the terraform service account
for project in $PRJ_SHARED_SERVICES $PRJ_APPLICATION; do
  echo "Granting permissions to service account on project $project"
  gcloud projects add-iam-policy-binding $project --member="serviceAccount:${SA_EMAIL}" --role=roles/owner
done

# Create the GCS bucket if it doesnt already exist
(gsutil du -s gs://$TF_STATE_BUCKET/ > /dev/null && echo "Bucket ${TF_STATE_BUCKET} already exists") || \
  (echo "Creating bucket ${TF_STATE_BUCKET}" ; gsutil mb -p $BUCKET_PROJECT_ID -l $BUCKET_REGION -b on gs://$TF_STATE_BUCKET)

# Grant permissions on the bucket
echo "Granting permissions on terraform remote state bucket"
gsutil iam ch serviceAccount:${SA_EMAIL}:objectAdmin gs://$TF_STATE_BUCKET

echo "Updating terraform configuration files"

# Update the terraform config files
export GCLOUD_USER
perl -e 's/myaccount\@my-domain.com/$ENV{"GCLOUD_USER"}/' -pi */params.tfvars
export NOTIFIERS_GROUP
perl -e 's/proxy-notifiers\@my-domain.com/$ENV{"NOTIFIERS_GROUP"}/' -pi */params.tfvars
export GCP_DOMAIN
perl -e 's/my-domain.com/$ENV{"GCP_DOMAIN"}/' -pi */params.tfvars
export SA_PATH
perl -e 's/^(\s*gcp_credentials_path\s*=\s*")([^"]+)(".*)$/$1$ENV{"SA_PATH"}$3/' -pi */params.tfvars
export PRJ_SHARED_SERVICES
perl -e 's/^(\s*project_id\s*=\s*")([^"]+)(".*)$/$1$ENV{"PRJ_SHARED_SERVICES"}$3/' -pi 01_shared_services/params.tfvars
export PRJ_APPLICATION
perl -e 's/^(\s*project_id\s*=\s*")([^"]+)(".*)$/$1$ENV{"PRJ_APPLICATION"}$3/' -pi 02_cn_zone//params.tfvars

# Update the folder ID
export FOLDER_ID
perl -e 's/^(\s*folder_id\s*=\s*")([0-9]+)(".*)$/$1$ENV{"FOLDER_ID"}$3/' -pi */params.tfvars

# Update the bucket name in the config files
export TF_STATE_BUCKET
perl -e 's/^(\s*bucket\s*=\s*")([^"]+)(".*)$/$1$ENV{"TF_STATE_BUCKET"}$3/' -pi */config.tf

# Update the remote state prefix in the config files
export TF_STATE_PREFIX
perl -e 's/^(\s*prefix\s*=\s*")([^"\/]+)(["\/].*)$/$1$ENV{"TF_STATE_PREFIX"}$3/' -pi */config.tf
