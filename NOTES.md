* removed etcd operator. Need to remove it from the manifests
* need to figure out how to connect to and use microk8s etcd. Or just run a single etcd node?
* this is the internal dns address: 10.152.183.2
* this has the etcd info I need: https://ops.tips/notes/kuberntes-secrets/
*
```
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://127.0.0.1:12379
export ETCDCTL_CACERT=/var/snap/microk8s/current/certs/ca.crt
export ETCDCTL_CERT=/var/snap/microk8s/current/certs/server.crt
export ETCDCTL_KEY=/var/snap/microk8s/current/certs/server.key
etcdctl get '/' --prefix=true -w json 

* so now I just need to figure how to generate a client cert for external dns, and then set it as a secret
* definitely in ansible land now
* To use kubectl on my desktop, juts did `microk8s config` and grabbed the output and put it in `$HOME}/.kube/config`
