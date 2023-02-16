#!/bin/bash
set -euo pipefail

read -rp 'instance name: ' INSTANCE_NAME
read -rp 'ubuntu version: [18, 20, 22(default)] ' INSTANCE_VERSION

PROJECT_ID=$(gcloud config get project)
MACHINE_TYPE="e2-medium"

case $INSTANCE_VERSION in
  18)
    ;;
  20)
    ;;
  22)
    gcloud compute instances create "$INSTANCE_NAME" \
      --machine-type="$MACHINE_TYPE" \
      --image=projects/"$PROJECT_ID"/global/images/ubuntu-pro-"$INSTANCE_VERSION"
    ;;

  *)
    echo "using default version: 22"
    gcloud compute instances create "$INSTANCE_NAME" \
      --machine-type="$MACHINE_TYPE" \
      --image=projects/"$PROJECT_ID"/global/images/ubuntu-pro-22
    ;;
esac
