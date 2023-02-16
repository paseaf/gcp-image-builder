#!/bin/bash
set -euo pipefail
# debug
# set -x
export DEBIAN_FRONTEND=noninteractive

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
