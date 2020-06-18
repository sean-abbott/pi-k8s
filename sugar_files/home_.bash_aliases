alias kubectl='microk8s kubectl'
alias helm='microk8s helm3'
alias showpodnodes='kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name --all-namespaces'
