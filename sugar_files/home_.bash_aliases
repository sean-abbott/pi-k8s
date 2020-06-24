alias kubectl='microk8s kubectl'
alias helm='microk8s helm3'
alias showpodnodes='kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name --all-namespaces'
alias etcdctl='kubectl run --rm -i --tty etcdctl --image docker.io/library/etcd:v3.4.9 --restart=Never -- /bin/sh'
# wiki port forward
alias wikipf='microk8s kubectl port-forward -n wiki service/wikijs 3000:3000'
