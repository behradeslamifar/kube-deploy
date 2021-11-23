#!/usr/bin/env sh

cat <<EOF | sudo tee /etc/apt/apt.conf.d/20proxy
Acquire::http::proxy::download.docker.com "${http_proxy}";
Acquire::http::proxy::apt.kubernetes.io "${http_proxy}";
Acquire::http::proxy::packages.cloud.google.com "${http_proxy}";
EOF

# Install Kuberntes components
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key FEEA9169307EA071
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Docker
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 8D81803C0EBFCD88
cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable
EOF

sudo apt-get update
sudo apt-get install -y kubelet=$kube_version kubeadm=$kube_version kubectl=$kube_version docker-ce=$docker_version docker-ce-cli=$docker_version
sudo apt-mark hold kubelet kubeadm kubectl docker-ce docker-ce-cli
sudo apt-get clean

# Set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Add proxy to Docker
sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}" "HTTPS_PROXY=${http_proxy}" "NO_PROXY=${no_proxy}"
EOF

# Add proxy to Containerd
sudo mkdir -p /etc/systemd/system/containerd.service.d
cat <<EOF | sudo tee /etc/systemd/system/containerd.service.d/override.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}" "HTTPS_PROXY=${http_proxy}" "NO_PROXY=${no_proxy}"
EOF


# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker containerd

#sudo rm /etc/apt/apt.conf.d/21proxy

# Disable swap
sudo swapoff --all
sudo sed -i '/^.*swap.*/ d' /etc/fstab

# Add shecan
#cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
## This file describes the network interfaces available on your system
## For more information, see netplan(5).
#network:
#  version: 2
#  renderer: networkd
#  ethernets:
#    enp0s3:
#      dhcp4: yes
#      dhcp4-overrides:
#        use-dns: no
#      nameservers:
#        addresses: [178.22.122.100,185.51.200.2]
#EOF

sudo netplan apply

exit 0
