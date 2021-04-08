# kube-deploy

# Version Table
| Component     | v0.1   |
| ------------- |:------:|
| Ubuntu        | 20.04  |
| Kubernetes    | 1.20   |
| Containerd    |        |
| Calico        |        |
| Keepalived    |        |
| HAProxy       |        |
| mon:kube-state-metric |  |
| mon:node-exporter     |  |
| mon:metric-server     |  |
| mon:blackbox_exporter |  |
| mon:Prometheus        |  |
| mon:prometheus-operator | |
| Ingress       |        |
| ceph-csi      |        |
| log:Filebeat  |        |
| log:Logstash  |        |



# Check list
## Master
* Script design (select master nodes create inventory with masters, worker and loadbalancer)
* Create kubeadm config file
  * kubelet listen on private network
  * enable limitrange, [ToDo]
* Install Kubernetes requirement packages (docker/containerd/crio, kubeadm, kubectl, kubelet)
* deploy masters
  * Idempotency (Check master1 api if running dont run again)
* Linux performance tuning
  * Disable swap
  * Disable IPv6
  * Network tuning
* Install nodelocaldns
  * https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache
  * https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/
  * https://v1-16.docs.kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/

## Worker
* Install Kubernetes requirement packages (docker/containerd/crio, kubelet)
* Linux performance tuning
  * Disable swap
  * Disable IPv6
  * Network tuning

## Loadbalancer
* Ingress loadbalancer
* API loadbalancer
* Linux performance tuning
  * Disable swap
  * Disable IPv6
  * Network tuning

## Networking
* Choose network cni plugin (calico, flannel, cannal) 
  * Calico: CrossSubnet, choose ipam (calico-ipam,host-local)

## Monitoring
* Deploy Node-exporter
* Deploy kube-state-metric
* Deploy metric-server
* Deploy Cadvisor
* Blackbox exporter
* Enable coredns metrics
* Deploy monitoring Stack (Grafana, Prometheus/Prometheus-operator)

## logging
* Enable audit log
* Deploy filebeat 

## Stroage
* ceph-csi

## Ingress  
* deploy ingress (nginx, haproxy, metallb) or service mesh (Istio, linkerd, ...)

## Security
* Node firewall
* bastion for access 
* fail2ban?
* wazuh
* ansible role for check node security
