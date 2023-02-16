#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
