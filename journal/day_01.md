[day 0](day_00.md)
Ok, got myself 4 64 bit *micro* SD cards. moving on again.
Writing ubuntu to it. Took a lot less time. Hit the verify stage after only a minute or so.
I brought a network cable up to connect directly to the device, but went ahead and just set wifi up on it.
AND NOW I JUST REALIZED THE LITTLE BASTARDS USE USB C ARRRRGGHHHH
Ok, well, I have some spare usb-c cables and I can order more of the right length fast enough. So I can keep going.
the recommended `arp -an` wasn't giving me anything without a port scan, so I just jumped on the router and found it.
ssh worked fine.

Ok, thoughts. I think the first thing I want up is DNS, but exposed to the house as a service. So I think I'll run a separate instance of coredns and expose it as a service. 

I definitely want to get like..flux working on this soon, as well, that may be what happens immediately after dns. Or before. Not sure.

Took me a minute, but I found out there is alpha :flushed_face: support for using coredns as the [external-dns provider](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/coredns.md). This is what I need.

(note, because I'm researching this during terraform runs for work, I still haven't actually brought up my cluster)

Ok, got all the boxes up, and wrote [a little script](../scripts/setup_key_ssh.sh) to setup passwordless ssh and disable password ssh. On to actually installing k8s!

Installed on the node I chose for the server, ssh setup (and notes about more automation later). Rebooting it to make sure k8s comes up after reboot...and it does! sweet.

On to installing the nodes...

ooo...need to add change the hostname to the setup

grr. My first bug. https://github.com/ubuntu/microk8s/issues/728

Let me see if this fix works...not quite. Also had to go here for a bit more clarity: https://askubuntu.com/questions/1189480/raspberry-pi-4-ubuntu-19-10-cannot-enable-cgroup-memory-at-boostrap . Steve's answer, changing cmdline.txt into a one-liner the the cpuset and whatnot, did it for me

Ok, and at this point, we have a node up and waiting for me to actually put some work on it. Will go for coredns tomorrow. I did notice that helm3 is already a microk8s command, so that's nice. I do wonder/assume? you could also just use helm3?

continued on [day 2](day_02.md)
