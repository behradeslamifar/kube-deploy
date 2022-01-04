# kube-deploy
Why another Kubernetes installer?  
* Kubespray has too many options and manual installation with kubeadm not repeatable. Our goul is installer that uses best practices and dont had many optional parameters.
* Initial cluster with kubeadm and you cant continue to maintain your cluster without this project
* Reusage roles in other cluster installation. We try write roles seprately and anybody can use them seprately

## Versions Table
| Component     |  v0.1 | Compatiblity Doc |
| ------------- |:------:| :--------------: | 
| Ubuntu        | 20.04  |   |
| Kubernetes    | 1.22.4 | [Kubernetes Dependencies - minimum version](https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml) |
| Containerd    |        | [Kubernetes Dependencies](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.22.md) |
| CoreDNS       | 1.8.4  | [Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#feature-11)
| etcd          |  3.4.13-3 | [Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#bug-or-regression-15)
| Calico        | 3.19.1 | [System Requirements](https://docs.projectcalico.org/archive/v3.16/getting-started/kubernetes/requirements)/[Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#bug-or-regression-15) |
| kube-state-metric   | 2.2.4  | [Compatibility matrix](https://github.com/kubernetes/kube-state-metrics#compatibility-matrix) |
| metric-server       | 0.6.x  | [Installation](https://github.com/kubernetes-sigs/metrics-server#installation) |
| prometheus-operator | 0.39.0 | [Prerequisites](https://github.com/prometheus-operator/prometheus-operator#prerequisites) |
| node-exporter       | 1.3.0 | [node-exporter release page](https://github.com/prometheus/node_exporter/releases) |
| Ingress             | 1.0.5 | [Changelog](https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md) |
| ceph-csi            | 3.4.0  | [Support Matrix](https://github.com/ceph/ceph-csi#support-matrix) |
| cri-tools           | 1.21.0 | [Kubernetes Dependencies](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.22.md) |

## Supported Linux Distributions
* Ubuntu 20.04

## Requirements
* Minimum required version of Kubernetes is v1.22
* Ansible v2.9.x

## Ansible tags

The following tags are defined in playbooks:

|                       Tag name | Used for
|--------------------------------|---------
|                       download | Pull container images
|                         sysctl | Configure sysctl in cluster nodes
