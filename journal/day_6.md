[day 5](day_5.md)

Got a little time. Ok. Everything is up and smooth today, unlike last time I came back to this. Great.

Time to see if coredns can be made to work. {crosses fingers}

First, let's go look and see if there's an arm64 coredns build yes `coredns/corends` from dockerhub, which has multi-arch manifests, and it works (ran locally with `--net=host` and queried it, it works). Great.

Ok, got corends working (and exposed to the rest of the network) with the yaml in manifets, pretty straight forward. Once I get external dns up, I'll have to also use what it puts in there to figure out how to add internal ip addresses (I think it's gonna be something like put etcd keys in the form of /skydns/com/myurl/mysubdomain/hostname ip, but dunno yet)


New problem is I'm gonna have to do my own build of external dns as well. There is [this](https://hub.docker.com/r/vchrisb/external-dns) referenced from a external-dns issue that got closed demonstrating you can do it, and [this](https://hub.docker.com/r/squat/external-dns-arm64) which is more recent...

ok, gonna use vchrisb's copy for starters, 'cause he filed the [issue](https://github.com/kubernetes-sigs/external-dns/issues/1139) to prove it could be done.

Alrighty, this all works! I'm not sure I"m gonna be able to capture the step by step well, enough, though.

In point of fact, though, I am able to both add loadbalancer services and manually include non-kubernetes services (via etcd key manipulation) into dns, and then I've got my router set up so that coredns is it's primary dns entry. So help me. :-) Fortunately both the router and the k8s hosts are still accessed via IP, so if anything blows up I won't be hung out to dry.

That's all for today! woot!

I think next time I'll probably work on setting up proxy services in kubernetes to manage non-k8s services on the backend (so I can get to plex and the nas and maybe even the router without ports).

After that, i think i'll finally be time for real kubernetes toys!

Hmm...as I try and capture everything I did I think Kustomize or something simliar is gonna need to happen soon. Don't want my local values on the interwebs.

[day 7](day_7.md)
