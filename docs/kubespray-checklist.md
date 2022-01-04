# Kubespray Checklist

## 1/5 Requirements
* Ansible v2.9 and python-netaddr is installed on the machine that will run Ansible commands
* Jinja 2.11 (or newer) is required to run the Ansible Playbooks
* The target servers must have access to the Internet in order to pull docker images. Otherwise, additional configuration is required 
* The target servers are configured to allow IPv4 forwarding
* Your ssh key must be copied to all the servers part of your inventory
* The firewalls are not managed, you'll need to implement your own rules the way you used to. 
* If kubespray is ran from non-root user account, correct privilege escalation method should be configured in the target servers. Then the ansible_become flag or command parameters --become or -b should be specified

## 2/5 Create Inventory
inventory/mycluster-v2.17.1/hosts.yml  
```
all:
  hosts:
    master-1:
      ansible_host: 192.168.43.202
      ip: 192.168.43.202
      access_ip: 192.168.43.202
    worker-1:
      ansible_host: 192.168.43.203
      ip: 192.168.43.203
      access_ip: 192.168.43.203
  children:
    kube-master:
      hosts:
        master-1:
    kube-node:
      hosts:
        worker-1:
        worker-2:
    etcd:
      hosts:
        master-1:
```

## 3/5 Plan your cluster deployment
[Plan your deployment](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
* Choice deployment mode: kubeadm or non-kubeadm
* CNI (networking) plugins
* DNS configuration
* Choice of control plane: native/binary or containerized
* Component versions
* Component runtime options
  * Containerd
  * CRI-O
* Choice of Addons
* Reserved Resources

### Choice Deployment Mode
$ vi inventory/sample/group_vars/all/all.yml
```
## Experimental kubeadm etcd deployment mode. Available 
## only for new deployment
etcd_kubeadm_enabled: false

## External LB example config
# loadbalancer_apiserver:
#   address: 1.2.3.4
#   port: 1234

## Internal loadbalancers for apiservers
# loadbalancer_apiserver_localhost: true
# valid options are "nginx" or "haproxy"
# loadbalancer_apiserver_type: nginx  

## Local loadbalancer should use this port
## And must be set port 6443
loadbalancer_apiserver_port: 6443

## Set these proxy values in order to update package 
## manager and docker daemon to use proxies
# http_proxy: ""
# https_proxy: ""

## Refer to roles/kubespray-defaults/defaults/main.yml 
## before modifying no_proxy
# no_proxy: ""
```

$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
## Settings for containerized control plane (kubelet/secrets)
kubelet_deployment_type: host
helm_deployment_type: host

# Enable kubeadm experimental control plane
kubeadm_control_plane: false
kubeadm_certificate_key: "{{ lookup('password', 
credentials_dir + '/kubeadm_certificate_key.creds 
length=64 chars=hexdigits') | lower }}"

# K8s image pull policy (imagePullPolicy)
k8s_image_pull_policy: IfNotPresent
```

### CNI (Networking) Plugin
$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
# Choose network plugin (cilium, calico, contiv, weave or 
# flannel. Use cni for generic cni plugin) Can also be set
# to 'cloud', which lets the cloud provider setup appropriate
# routing
kube_network_plugin: calico

# Setting multi_networking to true will install Multus: 
# https://github.com/intel/multus-cni
kube_network_plugin_multus: false

# Kubernetes internal network for services, unused block 
# of space.
kube_service_addresses: 10.233.0.0/18

# internal network. When used, it will assign IP
# addresses from this range to individual pods.
# This network must be unused in your network infrastructure!
kube_pods_subnet: 10.233.64.0/18

# internal network node size allocation (optional). This is 
# the size allocated to each node on your network.  With 
# these defaults you should have room for 4096 nodes with 254 
# pods per node.
kube_network_node_prefix: 24
```

$ vi inventory/sample/group_vars/k8s-cluster/k8s-net-calico.yml
```
# Choose data store type for calico: "etcd" or 
# "kdd" (kubernetes datastore)
calico_datastore: "kdd"

# IP in IP and VXLAN is mutualy exclusive modes.
# set IP in IP encapsulation mode: "Always", 
# "CrossSubnet", "Never"
calico_ipip_mode: 'CrossSubnet'

# set VXLAN encapsulation mode: "Always", 
# "CrossSubnet", "Never"
# calico_vxlan_mode: 'Never'
```

### DNS Configuration
$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
# Kubernetes cluster name, also will be used as DNS domain
cluster_name: cluster.local
# Subdomains of DNS domain to be resolved via
# /etc/resolv.conf for hostnet pods
ndots: 2
# Can be coredns, coredns_dual, manual or none
dns_mode: coredns
# Set manual server if using a custom cluster DNS server
# manual_dns_server: 10.x.x.x
# Enable nodelocal dns cache
enable_nodelocaldns: true
nodelocaldns_ip: 169.254.25.10
nodelocaldns_health_port: 9254

# Can be docker_dns, host_resolvconf or none
resolvconf_mode: docker_dns
# Deploy netchecker app to verify DNS resolve as 
# an HTTP service
deploy_netchecker: false
```

$ vi inventory/sample/group_vars/all/all.yml
```
## Upstream dns servers
upstream_dns_servers:
  - 8.8.8.8
  - 8.8.4.4
```

### Control Plane: native/binary or containerized
$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
# Enable kubeadm experimental control plane
kubeadm_control_plane: true
kubeadm_certificate_key: "{{ lookup('password', 
credentials_dir + '/kubeadm_certificate_key.creds
 length=64 chars=hexdigits') | lower }}"

# K8s image pull policy (imagePullPolicy)
k8s_image_pull_policy: IfNotPresent
```

$ vi inventory/sample/group_vars/etcd.yml
```
## Set level of detail for etcd exported metrics,
## specify 'extensive' to include histogram metrics.
# etcd_metrics: basic

## Settings for etcd deployment type (host or docker)
etcd_deployment_type: docker
```

$ vi inventory/sample/group_vars/all/all.yml
```
## Experimental kubeadm etcd deployment mode.
## Available only for new deployment
etcd_kubeadm_enabled: false
```

### Component Versions and Container Runtime
$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
## Change this to use another Kubernetes version, 
## e.g. a current beta release
kube_version: v1.22.4

# kubernetes image repo define
kube_image_repo: "k8s.gcr.io"
```

$ vi inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
```
## Container runtime
## docker for docker, crio for cri-o and containerd 
## for containerd.
container_manager: containerd

# Additional container runtimes
kata_containers_enabled: false
```

$ vi inventory/sample/group_vars/all/containerd.yml
```
## An obvious use case is allowing insecure-registry access to self hosted registries.
## Can be ipaddress and domain_name.
## example define mirror.registry.io or 172.19.16.11:5000
## Port number is also needed if the default HTTPS port is not used.
# containerd_insecure_registries:
#   - mirror.registry.io
#   - 172.19.16.11:5000
 
containerd_registries:
  "docker.io": "https://registry.docker.ir"
 
containerd_max_container_log_line_size: -1
 
# containerd_registry_auth:
#   - registry: 10.0.0.2:5000
#     username: user
#     password: pass
```

### Addons
$ vi inventory/sample/group_vars/k8s-cluster/addons.yml
```
# Kubernetes dashboard
# RBAC required. see docs/getting-started.md for access details.
dashboard_enabled: true

# Metrics Server deployment
metrics_server_enabled: false
# metrics_server_kubelet_insecure_tls: true
# metrics_server_metric_resolution: 60s
# metrics_server_kubelet_preferred_address_types: "InternalIP"

# Nginx ingress controller deployment
ingress_nginx_enabled: false
# ingress_nginx_host_network: false
ingress_publish_status_address: ""
# ingress_nginx_nodeselector:
#   kubernetes.io/os: "linux"
# ingress_nginx_tolerations:
#   - key: "node-role.kubernetes.io/master"
#     operator: "Equal"
#     value: ""
#     effect: "NoSchedule"
# ingress_nginx_namespace: "ingress-nginx"
# ingress_nginx_insecure_port: 80
# ingress_nginx_secure_port: 443

# Cert manager deployment
cert_manager_enabled: false
# cert_manager_namespace: "cert-manager"

# MetalLB deployment
metallb_enabled: false
# metallb_ip_range:
#   - "10.5.0.50-10.5.0.99"
# metallb_version: v0.9.3
```

### Reserved Resources
$ vi inventory/sample/group_vars/k8s-cluster/addons.yml
```
# A comma separated list of levels of node allocatable 
# enforcement to be enforced by kubelet.
# Acceptable options are 'pods', 'system-reserved', 
# 'kube-reserved' and ''. Default is "".
# kubelet_enforce_node_allocatable: pods

## Optionally reserve resources for OS system daemons.
# system_reserved: true
## Uncomment to override default values
# system_memory_reserved: 512M
# system_cpu_reserved: 500m
## Reservation for master hosts
# system_master_memory_reserved: 256M
# system_master_cpu_reserved: 250m
```

## 4/5 Deploy a Cluster
*  Ensure proxy setting for apt/yum
*  Revert your previous Docker config for prevent confilict with Kubespray
*  Cluster deployment using ansible-playbook.
*  [Large deployments](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/large-deployments.md) (100+ nodes) may require specific adjustments for best results.

```
$ ansible-playbook -i inventory/mycluster-v2.17.1/hosts.yaml  \
    -u user --become --become-user=root cluster.yml
```

## 5/5 Verify the Deployment
Kubespray provides a way to verify inter-pod connectivity and DNS resolve with [Netchecker](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/netcheck.md). [Netchecker](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/netcheck.md) ensures the netchecker-agents pods can resolve DNS requests and ping each over within the default namespace.


## Add/Replace, Remove a node
* Limitation: Removal of first kube-master and etcd-master
* Adding/replacing a worker node
* Adding/replacing a master node
* Adding an etcd node
* Removing an etcd node
* Reset installation
* [node documents](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/nodes.md)

```
ansible-playbook -i inventory/mycluster-v.2.17.1/hosts.yml \
  --user behrad --become  -e node=worker-4 remove-node.yml
```

```
ansible-playbook -i inventory/mycluster-v.2.17.1/hosts.yml \
  --become --become-user=root scale.yml
```

```
ansible-playbook -i inventory/mycluster-v.2.17.1/hosts.yml \
  --become --become-user=root reset.yml
```

## Upgrade 
```
ansible-playbook upgrade-cluster.yml --become \
  --becom-user=root -i inventory/mycluster-v.2.17.1/hosts.yml \
  -e kube_version=v1.22.5
```

