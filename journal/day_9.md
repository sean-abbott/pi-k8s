[day 8](day_8.md)
Ok, so, managed to fix a few things from yesterday.

First just rebooting the cluster seems to have cleared up the issues I was having, although I'd already mangled some stuff. I'm trying to get things back. 

As part of that, I discovered that I had screwed up my postgres install and postgres was writing to local storage, not the nfs container.

So then I discovered that nfsv4 is a pain in the ass with somewhat poorly described need to have a "domain" match between server and client. If there's a way to specific domain with client options, it wasn't immediately obvious. 

So I downgraded my nfs server to v3 (probably could leave it at v4; there is an obvious option to have the client request v3). 

The issue, which you'll see in the new postgres manifest, is that postgres expects the data directory to be owned by whatever user postgres is running at. But nfsv4 wouldn't allow it to set the user, because reasons.

By setting to v3, we can arbitrarily set the user, and then run an init container as root to ensure that that user lines up with the default postgres uid and gid.

But even so, we're STILL not using the bloody thing. GAHHH. Well, I get to test the other part of my part of my day's discoveries, which was "how to backup my wiki outside of my obviously still fragile k8s cluster"

There's a way to back it up to github (yay) which is currently fairly labor intensive (boo) but since I have to redo it right now anyway, oh well, lemme see if I can't make it better.

Ok, got the database up AND ACTUALLY WORKING, left it with v3 nfs because I am a lazy coward, and got the backup working.

The "labor intensity" of getting the github backup setup isn't TOO bad, but I should look to see if there's a way I can populate the files as part of k8s. I'll add that to the techdebt.



[day 9](day_9.md)
