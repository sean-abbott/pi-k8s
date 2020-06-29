[day 7](day_7.md)
Booted up a few of the x86 boxes I had today. One of them is working, one of them (an old atom) was just too effin' slow to bother with, and the other one the nic got burnt out in a power spike and I can't find the usb nic I bought for it, so it's offline unti I buy one.

But today we do a little experiment with multi-arch. And more generally, plus up the early stage ubuntu stuff, 'cause forget doing this stuff manually over and over.

<quick interlude where I ask on facebook :puke: if anyone in the area has any old machines they wanna give me>

Ok, back. Now, lessee...


Oh yeah...we're gonna have to sweep all the existing manifests and whatnot and put an affinity on anything that's not using a dockerhub multi-arch repo. Blarg.

Note 1: the hp takes a lot longer to come back up than the pi's do.

Oy. The example sudoers.d file had `.conf`, but the README says you can't use `.` in a filename and have it picked up in the include. That's...annoying, and cost me 30 minutes.

Just noticed the deault backend for the nginx ingress is in a crash backoff loop, PROBABlY because it's the wrong image type. Adding that to the techdebt.

Nice. metallb speaker just picked up and started running on the new node. perfect.

Ok, added a README section to update affinity

Ah, need to run the nfs-client ansible on the new box...that worked nicely.

Ok, so the next thing will be to get he listed affinities set up, and then the next FUN thing will probably to be to get plex and cups running on k8s, and then switch my current server to also run k8s.

Oh...also need to look into wake on lan for this silly x86 box I've got, 'cause "reboot" failed to actually bring it back up. I had to walk down to the basement and turn it on.

[day 9](day_9.md)
