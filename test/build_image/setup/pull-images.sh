#!/usr/bin/env sh

# Select container-runtime socket
case ${container_runtime} in
  docker) container_runtime_socket="/var/run/docker.sock"
  ;;
  containerd) container_runtime_socket="/var/run/containerd/containerd.sock"
  ;;
  crio) container_runtime_socket="/var/run/crio/crio.sock"
  ;;
esac

# Configure crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix://$container_runtime_socket
image-endpoint: unix://$container_runtime_socket
timeout: 30
debug: false
pull-image-on-create: false
EOF

if [ "$container_runtime" == "docker" ]
then
  # Pull kubernetes images
  sudo kubeadm --kubernetes-version ${kube_version%-*} config images pull
  
  # Pull Calico images
  sudo docker pull calico/cni:${calico_version}
  sudo docker pull calico/pod2daemon-flexvol:${calico_version}
  sudo docker pull calico/node:${calico_version}
  sudo docker pull docker.io/calico/kube-controllers:${calico_version}
elif [ "$container_runtime" == "containerd" ]
then
  # Pull kubernetes images
  sudo kubeadm --kubernetes-version ${kube_version%-*} config images pull --cri-socket=$container_runtime_socket

  # Pull Calico images
  sudo crictl pull docker.io/calico/cni:${calico_version}
  sudo crictl pull docker.io/calico/pod2daemon-flexvol:${calico_version}
  sudo crictl pull docker.io/calico/node:${calico_version}
  sudo crictl pull docker.io/calico/kube-controllers:${calico_version}
fi

exit 0
