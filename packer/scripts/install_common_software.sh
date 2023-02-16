#!/bin/bash
set -euo pipefail

source /var/tmp/scripts/apt_get_wait_lock.sh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y git tmux neovim vim net-tools build-essential
