## kube-vip

As an alternative to the more "traditional" approach of `keepalived` and `haproxy`, [kube-vip](https://kube-vip.io/) implements both management of a virtual IP and load balancing in one service. Similar to option 2 above, `kube-vip` will be run as a static pod on the control plane nodes.

Like with `keepalived`, the hosts negotiating a virtual IP need to be in the same IP subnet. Similarly, like with `haproxy`, stream-based load-balancing allows TLS termination to be handled by the API Server instances behind it.

The configuration file `/etc/kube-vip/config.yaml` looks like this:
```yaml
localPeer:
  id: ${ID}
  address: ${IPADDR}
  port: 10000
remotePeers:
- id: ${PEER1_ID}
  address: ${PEER1_IPADDR}
  port: 10000
# [...]
vip: ${APISERVER_VIP}
gratuitousARP: true
singleNode: false
startAsLeader: ${IS_LEADER}
interface: ${INTERFACE}
loadBalancers:
- name: API Server Load Balancer
  type: tcp
  port: ${APISERVER_DEST_PORT}
  bindToVip: false
  backends:
  - port: ${APISERVER_SRC_PORT}
    address: ${HOST1_ADDRESS}
  # [...]
```

The `bash` style placeholders to expand are these:
- `${ID}` the current host's symbolic name
- `${IPADDR}` the current host's IP address
- `${PEER1_ID}` a symbolic name for the first vIP peer
- `${PEER1_IPADDR}` IP address for the first vIP peer
- entries (`id`, `address`, `port`) for additional vIP peers can follow
- `${APISERVER_VIP}` is the virtual IP address negotiated between the `kube-vip` cluster hosts.
- `${IS_LEADER}` is `true` for exactly one leader and `false` for the rest
- `${INTERFACE}` is the network interface taking part in the negotiation of the virtual IP, e.g. `eth0`.
- `${APISERVER_DEST_PORT}` the port through which Kubernetes will talk to the API Server.
- `${APISERVER_SRC_PORT}` the port used by the API Server instances
- `${HOST1_ADDRESS}` the first load-balanced API Server host's IP address
- entries (`port`, `address`) for additional load-balanced API Server hosts can follow

To have the service started with the cluster, now the manifest `kube-vip.yaml` needs to be placed in `/etc/kubernetes/manifests` (create the directory first). It can be generated using the `kube-vip` docker image:
```
# docker run -it --rm plndr/kube-vip:0.1.1 /kube-vip sample manifest \
    | sed "s|plndr/kube-vip:'|plndr/kube-vip:0.1.1'|" \
    | sudo tee /etc/kubernetes/manifests/kube-vip.yaml
```

The result, `/etc/kubernetes/manifests/kube-vip.yaml`, will look like this:
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: kube-vip
  namespace: kube-system
spec:
  containers:
  - command:
    - /kube-vip
    - start
    - -c
    - /vip.yaml
    image: 'plndr/kube-vip:0.1.1'
    name: kube-vip
    resources: {}
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - SYS_TIME
    volumeMounts:
    - mountPath: /vip.yaml
      name: config
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kube-vip/config.yaml
    name: config
status: {}
```

With the services up, now the Kubernetes cluster can be bootstrapped using `kubeadm init` (see [below](#bootstrap-the-cluster)).

## Bootstrap the cluster

Now the actual cluster bootstrap as described in [Creating Highly Available clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/) can take place.

Note that, if `${APISERVER_DEST_PORT}` has been configured to a value different from `6443` in the configuration above, `kubeadm init` needs to be told to use that port for the API Server. Assuming that in a new cluster port 8443 is used for the load-balanced API Server and a virtual IP with the DNS name `vip.mycluster.local`, an argument `--control-plane-endpoint` needs to be passed to `kubeadm` as follows:

```
# kubeadm init --control-plane-endpoint vip.mycluster.local:8443 [additional arguments ...]
```
