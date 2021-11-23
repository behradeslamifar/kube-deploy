#!/usr/bin/env sh

# Pull kubernetes images
sudo kubeadm --kubernetes-version ${kube_version} config images pull

# Pull Calico images
sudo docker pull calico/cni:${calico_version}
sudo docker pull calico/pod2daemon-flexvol:${calico_version}
sudo docker pull calico/node:${calico_version}
sudo docker pull docker.io/calico/kube-controllers:${calico_version}

# Remove proxy
#sudo rm /etc/systemd/system/docker.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart docker

exit 0
