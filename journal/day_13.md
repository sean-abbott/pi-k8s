[day 12](day_12.md)
So, things got really weird after that last journal. Everything was broken, because I was putting a new router in the house I despaired of getting anything working again, and just...yeah. Stuff was weird.

Now stuff is only SORTA weird? The API changed for the ingress annotations (which you'll see when I finally commit this in the manifests), and I can't get the wiki to work and I'm getting tls api errors in the logs from coredns which is set up to wtach the k8s system etcd.

```
E0104 23:23:40.531451       1 reflector.go:307] pkg/mod/k8s.io/client-go@v0.17.4/tools/cache/reflector.go:105: Failed to watch *v1.Endpoints: Get "https://10.152.183.1:443/api/v1/endpoints?allowWatchBookmarks=true&resourceVersion=70946746&timeout=6m49s&timeoutSeconds=409&watch=true": net/http: TLS handshake timeout
```

The etcd part is working; I can access etcd. Manual entries to etcd work. What isn't working is watching the api. Although. Come to think of it, microk8s probably already had it reading from the api? So maybe I didn't need to do all that shit with certs, and it'd defacto use the same certs to read etcd as the k8s api, in this case?

Anyway. I'm annoyed with not being able to mess around without risking my running services, and I'm ALSO annoyed by how flaky a lot of this has been, although I truly think MOST of that was the etcd operator being a shit show.

So I'm gonna set up a test cluster. I also want to have a mixed architecture cluster, and I want to take advantage of the new HA capabilities. 

So, moving more slowly, I'm gonna try and write ansible to bring the whole thing up and get the baseline components (almost everything I have currently, minus the wiki) in place that way.

I'm gonna try and do this is smaller chunks, if life lets me. Today. Adding a pi (or two?) and an x86 box into a cluster. And seeing if I can do ANYTHING with it.

In preperation, I've edited the metallb config (`microk8s kubectl edit ConfigMap/config -n metallb-system`) for my current (not production) cluster to use only a /25, segmenting my network into 192.168.x.0/23 for my actual router, 192.168.x.0/24 for my lan/wireless dhcp server on said router, then 192.168.x+1.0/25 for the production cluster and 192.168.x+1.128/25 for the test cluster. Hopefully, that means my network will all still basically Just Work. :prays to fsm:

I think one thing I learned is that even though auto-updates would be nice, I'm gonna version lock because getting ambushed by k8s upgrades kinda sucks. I'd rather do it on purpose. which is probably ALSO gonna suck, but at least hopefully I'll get to choose when it sucks?

I think I'm going to try making the x86 box the master node. Then, my tenative plan is to TRY using affinity to lock every new app to arm, and if it fails, lock it to x86.

Oh, just remembered, another high priority here is to start using kustomize or some other config management that will allow me to use the same manifests in this public repo as I use locally, and keep all my secrets/private information in another place I can merge.

[day_14](day_14.md)
