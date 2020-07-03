[day 6](day_06.md)

Ok, I actually didn't capture a fair amount of work and rubber ducking here, but I have a wiki up, using the ingress and getting an internal host name. My very first service!

So there were 4 pieces to getting this done.
1) nfs-client-provisioner, which allows us to do persistent volumes, which was necessary for...
1) postgres, providing a database. I left this databse as specific to the wiki, as opposed to one database with multiple schemas. It's proper separation, but also going to be more expensive in terms of resources on this little cluster.
1) wiki service itself. not to big a deal, just had to get the service linkage working to read / write the db
1) ingress controller and ingress


A big hangup I had was figuring out the relationship between the ingress controller, the desired URL, metallb, and the rest of the system. I'm still not sure why I wouldn't just expose the service for the wiki as a loadbalancer and get it's own hostname and IP, but we went the ingress route. So...cool. Apparently we could do more routin if we needed? And probably if I start doing any kind of like oauth this'll be better. Anyhoo...it's working now, so I'll have to get it swung back around to see the rest of it working.

[day 8](day_08.md)
