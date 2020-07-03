[day 9](day_9.md)
So, I've got a little staycation happening, so likely I'll be doing a fair bit.

Today, I already experimented with using nfsv3 on the nfs-client provisioner. And it worked! yay! So once I actually get all the new manifests in, you'll see that. It's adding tech debt, though, as I've decided NOT to recreate the postgres db and the wiki yet. So next time I *do* have to recreate them, I'll need to remember to update them to work with nfsv3 not 4. But! I am running both provisioners (v3 and de-factor v4) at the same time. (To recap: v3 was necessary to allow postgres to change permissions since I didn't want to learn enough nfs to figure out v4 domains. I was just going to leave my server at v3, but then I found out my existing coreos based server, with plex on it, couldn't use v3 for some reason. So I re-reverted the server to v4, which then means any postgres instances will need to use the v3 nfs client provisioner. I think that catches us up.)

I think I'm gonna spend the extra $100 to buy 2 more RPis that I can use as a dev environment. Specifically, first, I wonder if my introduction of a different architecture somehow borked the networking, and I want to test that separte from my working pi cluster. Technically, I COULD do it just by taking two of my pis out of the existing cluster but...fuckit, I've got enough money, and I like working with a dev environment better anyway. Plus, it'll give me more reasons to automate.  So that will probably happen today, since I'm off anyway, and now it's been more than a week since my last microcenter run. ;-)

Also, this looks very interesting: https://kubernetes.io/blog/2020/06/working-with-terraform-and-kubernetes/. I wonder if that alpha provider might be worth me trying out. 

I'm also curious about using ansible more directly to drive k8s stuff, especially for automating bring up the stack as a whole. But I want to be more familiar with the direct tools that everyone will have before I go down that route.

Also, talking with a friend today I'm thinking that maybe I should spend some time to get the BGP version of metallb working later. Seems like having all the DNS queries hit not one but TWO services behind metallb may mean that I don't want a single node bottle-necking that. Not sure.

Anyhoo..I got my two new pis and I'm gonna set up a dev network. Probably, the still manual setup will eat up tonight, but then I want to see if it was mixed architecture that borked my network last week.


Annnndd....one of the new pi's isn't comign up on the network..FML.

[day 11](day_11.md)
