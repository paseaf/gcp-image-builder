#!/bin/bash
# Cowrie installation scripts based on https://cowrie.readthedocs.io/en/latest/INSTALL.html
set -euxo pipefail

source /var/tmp/scripts/apt_get_wait_lock.sh
export DEBIAN_FRONTEND=noninteractive
# Install Cowire system deps
apt-get update -y
apt-get install -y git tmux neovim vim net-tools build-essential
