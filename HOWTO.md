# HOWTOs
A bunch of things I don't wanna have to look up later

### Login to the dashboard
1) ssh -L 10443:127.0.0.1:10443 piserver
1) token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
1) microk8s kubectl -n kube-system describe secret $token
1) microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
1) open https://127.0.0.1:10443 in browser
1) enter the token found therein

### use etcdctl
Largely from https://github.com/coreos/etcd-operator/blob/master/doc/user/client_service.md
1) `kubectl -n etcd run --rm -i --tty etcdctl-test --image docker.io/library/etcd:v3.4.9 --restart=Never -- /bin/sh` (note this is the LOCAL etcd image we created and added on each node)
1) `ETCDCTL_API=3 etcdctl --endpoints http://etcd-client:2379 <your etcd commands`
1) So for example:
    ```
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 put foo bar
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client:2379 get foo
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client:2379 del foo
    ```
1) OR if you want to use etcd from another namespace (this example should be apropos of coredns' service endpoint:
    ```
    # note this is no longer in the etcd namespace
    kubectl run --rm -i --tty fun --image docker.io/library/etcd:v3.4.9 --restart=Never -- /bin/sh
    # now see the new url. The form is http://<cluster-name>-client.<cluster-namespace>.svc.cluster.local:2379
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 put foo bar
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 get foo
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 del foo
    ```

### check on etcd entries for home
    ```
    kubectl run --rm -i --tty fun --image docker.io/library/etcd:v3.4.9 --restart=Never -- /bin/sh
    ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 get /skydns/com/example --prefix
    ```

### add a non-kubernetes domain into coredns
Note: there's an error message about this in the logs that I need to figure out. I think "owner" needs to be added as well?
1) connect to etcdctl.
1) put json map with "host and ttl values in under a key `/skydns/com/example/subdomain/host`, i.e.: `ETCDCTL_API=3 etcdctl --endpoints http://etcd-client.etcd.svc.cluster.local:2379 put /skydns/com/example/k8s/plex '{"host":"192.168.1.7","ttl":60}'`

### verify yoru postgres, or connect to it
1) `export POSTGRES_PASSWORD=<the password you used>`
1) `kubectl run pgsql-postgresql-client --rm --tty -i --restart='Never' --namespace wiki --image arm64v8/postgres:12 --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- psql testdb --host postgres -U wiki -d wiki -p 5432`

