# HOWTOs
A bunch of things I don't wanna have to look up later

### Login to the dashboard
1) ssh -L 10443:127.0.0.1:10443 piserver
1) token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
1) microk8s kubectl -n kube-system describe secret $token
1) microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
1) open https://127.0.0.1:10443 in browser
1) enter the token found therein
