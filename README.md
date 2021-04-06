# kube-deploy

# Check list
## Master
* Script design (select master nodes create inventory with masters, worker and loadbalancer)
* Create kubeadm config file
* Install Kubernetes requirement packages (docker/containerd/crio, kubeadm, kubectl, kubelet)
* deploy masters
* Linux performance tuning

## Worker
* Install Kubernetes requirement packages (docker/containerd/crio, kubelet)
* Linux performance tuning

## Loadbalancer
* Ingress loadbalancer
* API loadbalancer
* Linux performance tuning

## Networking
* Choose network cni plugin (calico, flannel, cannal) 
* Choose deployment method (L2/L3)

## Monitoring
* Deploy Node-exporter
* Deploy kube-state-metric
* Deploy metric-server
* Deploy Cadvisor
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
