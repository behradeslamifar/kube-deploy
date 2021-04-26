# kube-deploy

## Version Table
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



## Check list
### Master
* Master
  * --admission-control=PodNodeSelector,NamespaceLifecycle
  * --audit-policy-file=/etc/kubernetes/policies/audit.yaml
  * --audit-log-path=/var/log/apiserver/audit.log
  * --audit-log-maxage=30
  * --audit-log-maxsize=200
  * --audit-log-maxbackup=10
  * quota
```
    resources:
      limits:
        cpu: 4
        memory: 10G
      requests:
        cpu: 1
        memory: 6G
```
* Script design (select master nodes create inventory with masters, worker and loadbalancer)
* Create kubeadm config file
  * [kubeadm config](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/)
  * [kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#config-file)
  * [kubeadm phases](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/)
  * [kubeadm join](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/#config-file)
  * kube-proxy config
  * [kubelet-config](https://pkg.go.dev/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2?utm_source=godoc#hdr-Kubeadm_join_configuration_types)
    * [kubelet dynamic config](https://kubernetes.io/docs/tasks/administer-cluster/reconfigure-kubelet/)
    * --dynamic-config-dir /etc/kubernetes/kubelet_dynamic_dir
```
# enable dynamic config
vi /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--address=192.168.13.202 --cgroup-driver=systemd --network-plugin=cni --node-ip=192.168.13.202 --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf --dynamic-config-dir /etc/kubernetes/kubelet_dynamic_dir"

systemctl restart kubelet

kubectl edit node <node_name>
spec:
  configSource:
    configMap:
      kubeletConfigKey: kubelet
      name: kubelet-config-1.18
      namespace: kube-system

or

kubectl patch node ${NODE_NAME} -p "{\"spec\":{\"configSource\":{\"configMap\":{\"name\":\"${CONFIG_MAP_NAME}\",\"namespace\":\"kube-system\",\"kubeletConfigKey\":\"kubelet\"}}}}"

check status
kubectl get no master-1 -o json | jq '.status.config'
```
    * kubelet listen on private network
    * kubelet rotate certificate(--rotate-certificates, --rotate-server-certificates)
    * --allowed-unsafe-sysctls 'net.core.somaxconn,net.ipv4.tcp_syn_retries'
* Install Kubernetes requirement packages (docker/containerd/crio, kubeadm, kubectl, kubelet)
* deploy masters
  * Idempotency (Check master1 api if running dont run again)
* Linux performance tuning
  * Disable swap
  * Disable IPv6
  * Network tuning
  * NIC ring buffer
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
* Per node LB
  * [kubespray ha mode](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ha-mode.md)
  * [kubespray local LB role](https://github.com/kubernetes-sigs/kubespray/tree/master/roles/kubernetes/node/tasks/loadbalancer)
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

## Addons
* cert-manager
* dashboard
