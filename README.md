# kube-deploy
Why another Kubernetes installer?  
* Kubespray has too many options and manual installation with kubeadm not repeatable. Our goul is installer that uses best practices and dont had many optional parameters.

## Versions Table
| Component     |  v0.1 | Compatiblity Doc |
| ------------- |:------:| :--------------: | 
| Ubuntu        | 20.04  |   |
| Kubernetes    | 1.20.5 | [Kubernetes Dependencies - minimum version](https://github.com/kubernetes/kubernetes/blob/master/build/dependencies.yaml) |
| Containerd    |        | [Kubernetes Dependencies](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md) |
| CoreDNS       | 1.7.0  | [Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#feature-11)
| etcd          | 3.4.13 | [Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#bug-or-regression-15)
| Calico        | 3.15.2 | [System Requirements](https://docs.projectcalico.org/archive/v3.16/getting-started/kubernetes/requirements)/[Kubernetes 1.20 Changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#bug-or-regression-15) |
| kube-state-metric   | 2.1.1  | [Compatibility matrix](https://github.com/kubernetes/kube-state-metrics#compatibility-matrix) |
| metric-server       | 0.6.x  | [Installation](https://github.com/kubernetes-sigs/metrics-server#installation) |
| prometheus-operator | 0.39.0 | [Prerequisites](https://github.com/prometheus-operator/prometheus-operator#prerequisites) |
| node-exporter       | 0.18.0 | |
| Ingress             | 0.46.0 | [Changelog](https://github.com/kubernetes/ingress-nginx/blob/master/Changelog.md) |
| ceph-csi            | 3.2.1  | [Support Matrix](https://github.com/ceph/ceph-csi#support-matrix) |
