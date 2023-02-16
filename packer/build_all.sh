#!/bin/bash

set -euo pipefail
# print commandes for debugging
# set -x

if [ "$#" -ne 2 ]; then
  >&2 echo "Usage: ./build_all.sh <gcp_project_id> <zone>"
else
  echo "Building for GCP project ID: $1 using zone $2"
fi

export PKR_VAR_project_id="$1"
export PKR_VAR_zone="$2"

packer validate .
packer fmt .
packer build -force .
