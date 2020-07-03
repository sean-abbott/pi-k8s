[day 2](day_02.md)

Alrighty. Had a day off for gardening. Likely won't get much time todya. But...gonna start trying external-dns with coredns. Pointing here: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/coredns.md

I know I could technically just use the system etcd...but I prefer separation of concerns.

Although I should probably also get prometheus / grafan up and running so I can monitor cpu and whatnot. (And with prometheus / grafana, I'd almost be tempted to JUST run prometheus and alertmanager, and just run grafana on my desktop when I wanna take a look at things.

Ehhh...let's start with the dashboard, and see how far that gets us. I wanna also learn the RBAC pieces, BUT I think I'm gonna have to do that either in a second round, or bolting it on. I want some useful services.

Ok, the dashboard is up and working and that was straight forward, BUUUT we have our first operational issue.

The kubelet/worker pod on the server itself (`piserver`) in my parlance, is down and not responding.

I SUSPECT this is has something to do with the hostname change (which, maybe I needed to do before I started microk8s? Anyway, trying a restart. Since this is the server node, I'm afraid I'm gonna have to tear down/restart the whole system.

Fuck. Now the ssh proxy isn't working. what the hell?

Ha ha...yeha...trying to get the serer node back into the cluster just fucked everything to a non-recoverable status. So...Guess I have to re-install the server.  :sad_trombone:

Ok, so a snap remove and reinstall without anythign drastic gets k8s back up. Let's try the dashboard first this time.

Ok, dashboard is working, this time all nodes are up. Let's try metallb again. Ok, installed, pods are all up. We're back to 0.8.2 instead of 0.9.3...trying the manifest...yup, nginx is back. Everything is currently working. Weird. Very weird.

Alrighty, well...I guess I'll try the prometheus add-on. Man, I wish the docs on this stuff were more full-flavored.

Oh. that's a lie.
```
$ microk8s enable prometheus
Nothing to do for prometheus
```

Oookkkkk

Fuck. Ok. That means prometheus is going to be a separate service to install. And I don't really feel like it that much.

So back to the coredns idea.

First up, let's see if helm3 addon works and can install the etcd-operator.

Ah. Hmm...it wants "clusterdns". I'm gonna try just using the microk8s dns first. There's some irony, huh?

Well, fuck: `standard_init_linux.go:207: exec user process caused "exec format error"` is what the damn descirbe gives me on the..ohhhhhhh fuck amd64, i'll bet. Oh, hell.


Ok. Went for a hike. Next question. Can we get the etcd operator to work on arm? Image comes from quay.io. There aren't any other versions, so assume amd64 is the baseline. 

Looks like there was a problem on arm do to int overflow, but no one has mentioned arm64, so maybe worth a shot.

Ok, so it'll build on arm64. Now if it'll run. Probably gonna have to install the local images for that, which probably means I'm done for the evening

Ok, so I installed docker (it was 19.03, so close enough) with apt (`sudo apt install docker,io`), and then built the image for the etcd operator (`sudo docker build -t local-etcd-operator -f hack/build/Dockerfile .`). guess it's worth noting that I skipped a step; I also installed go, go dep, and set up the necessary structure in the server's ubuntu home directory. Ergh, ok, attempting to document.

Ok, documentation done. Tomorrow, need to start with getting the image into k8s (https://microk8s.io/docs/registry-images), and then need to figure out how to overlay the helm chart we were trying to sue (https://github.com/helm/charts/tree/master/stable/etcd-operator), which should be available using `value.yaml`. Just have to remember how. :-)

But that's it for today.

[day 4](day_04.md)
