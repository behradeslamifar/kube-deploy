#!/usr/bin/env sh

set -e

# cleanup cloud-init data
sudo cloud-init clean

# cleanup cloud-init logs
sudo rm /var/log/cloud-init*
