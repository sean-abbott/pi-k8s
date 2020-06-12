[day 1](day_1.md)
Ok, it's really fucking hot outside, so time to stop gardening and start mucking with k8s. It's always a bit disconcerting, for me, at these points. As it stands right now, the system is "working". As soon as I embark on the next piece, it will STOP working, even if I don't break it so bad that what is currently working stops working. It's a state that I find a little daunting at times.

Anyhoo...on to getting external-DNS up, using a coredns installed on the machine. I don't know whether I should do metallb first or etcd...

I think I'm gonna try metallb first, because microk8s makes it sound like it's easy and I am almost positive it will not be.

Hmm...whelp, metallb is up and now I need to test it and...that probably means deploying like nginx or some shit.

Hmm..there's not much to it, but it looks like I might need to change my network so that it knows more about this. Still..hoping arp will make this work anyway. I chose a different ip subnet than my router uses for dhcp, but hopefully the arp will work anyway? Not surehow to set this up.  anyway, I'm gonn try just the simple nginx server from the [metallb tutorial](https://v0-3-0--metallb.netlify.app/tutorial/arp/).


Ok, it looks like I'm probably going to need to reduce the IPs available to my DHCP set up my router, but after talking with a networking buddy, I'm kinda hoping that metallb can discover it. I gave metallb 200-254 in the interim. 

If I do have to reduce the range, I'll probably end up giving dhcp half the addresses to dhcp with a /25, and then giving k8s the other /25. Which is way too many for k8s and someday might not be enough for the home network because of the internet of shit, but whatcha gonna do?

I could also just set up another router, actually. That would be a thing I could do. I have an edgerouter sitting on my desk I bought like 2 years ago and never did anythign with. It was gonna be a vpn or me.

Today I also learned that `get all` doesn't actually get everything. For instance, I had to go looking explicitly for the config map that was controlling the metallb deployment. Also, editing it didn't cause it to reboot (and it wasn't until later that I found the "how to restart" guide below

Grr...i was made hopeful becaues I was looking at an old version of the docs, and they no longer offer the ....

FUCK YEAH! It works. I gave the router /23, kept it's DHCP the same, and gave metallb the other subnet. Woot!

[day 3](day_3.md)

Useful links from today:
https://wiki.wireshark.org/Gratuitous_ARP gives me some hope that metallb will be able to detect conflicts.
https://medium.com/faun/how-to-restart-kubernetes-pod-7c702ca984c1  was looking forthis earlier, so I could change the metallb config maps and see what works


