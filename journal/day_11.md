[day 10](day_10.md)

## Day 11
I've decided that even though one of my new "dev" pi's isn't coming up, I'm going to leave that for when I have the new case in hand, because the wire tangle isn't tenable. So today: pihole.

I spent the first 20 minutes or so syncing up the work that I'd done getting the wiki up and solid, and then fixing the journal so it lists correctly.

Now. Pihole on k8s. An extra DNS layer. There's too much DNS going on. That's gonna bite me.


Anyway. Got started just doing a [manual setup](https://medium.com/@subtlepseudonym/pi-hole-on-kubernetes-87fc8cdeeb2e), but the I found [a chart](https://github.com/MoJo2600/pihole-kubernetes/tree/master/charts/pihole) while trying to figure out how to set the upstream DNS as part of the kubernetes manifests. In neat things, it already comes with metallb setup info, so sa-weet, gonna use that. 

First, though, I need to get my upstream DNS to claim it's own IP. Which means I'm gonna take it down. Hopefully it comes back up. */me shivers*

So new plan is to have coredns reside on .0, and then pihole reside on .1 and use .0 as it's upstream, and then when all that's working well, point my router's dhcp at .1, with a backup at .0. Although, arguably, when this is working, I shouldn't even be exposing coredns outside k8s, but I suspect that way lies madness was DNS inevitably fails. Plus, I don't know how to reserve a clusterIp, and I don't want pihole having to reolve the coredns address via dns every time.

Ah. Actually, I can also request a specific ClusterIP, so I can lock my coredns to a particular clusterIP, and then use that clusterIP for coredns. 

This is where I start to miss terraform, and actually, as noted a couple of days ago, might want to run all this stuff with terraform. I don't like having to specify and sync that IP address in multiple manifests...I want to specify it once and then use (in terraform parlance) the output from the original resource to give me the value for the dependent resource.


Ok...it's actually been way longer than just the one day, 'cause I took some time away, and then thing came up, and whatnot and so worth. And there's a bunch of shit I need to get moving over from the actual boxes, and I DEFINITELY need to get kustomize or something going on so I can directly use these manifests and not maintain 2 copies because secrets.  Anyway, since the last commit I have:

* learned about cdk8s
* sent PRs to [termshark](https://github.com/gcla/termshark) and [netshoot](https://github.com/nicolaka/netshoot) to make them multi-arch (and already had the termshark one merged)
* created a little docker hub repo and arm network troubleshooting image of my own: https://hub.docker.com/r/seanabbott/micro-netsht
* fixed a few things...again.
* found out my one pi wasn't working because I didn't plug in the bloody sd card

[day 12](day_12.md)
