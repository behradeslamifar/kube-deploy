#!/usr/bin/env sh

# disable translate download and add proxy
cat <<EOF | sudo tee /etc/apt/apt.conf.d/20translate
Acquire::Languages "none";
EOF

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-guest-agent apt-transport-https curl ca-certificates software-properties-common gnupg2 vim traceroute bash-completion python3-minimal
sudo systemctl enable qemu-guest-agent
