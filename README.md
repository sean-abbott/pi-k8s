# pi-k8s
A journey with raspberry pis and k8s. See the [journal](journal/day_0.md) for daily decisions and what not.

I'm intending to try and make everything that I do accessible from here, minus any secrets that I use. This repository is probably going to be ugly, because this is just the learning process for now. Maybe I'll clean up later, but home projects don't tend to last to clean up phase with me.

## Intentions
I don't think I'm being too ambitious with this righ tnow.

* Learn me some k8s
* do NOT devolve into lots of sysadmin or trying to make this perfectly replicable
* Run plex
* run multiarchitecture, use affinity to run a cups server on my x86 box with the attached printer
* run a household wiki
* run an internal dns server to make things easier to access
* run openFaaS and get some triggers based on the world. Temperature. That sort of thing. Maybe later get another pi and use it to water things.

## longer stretch goals
* make this publicly accessible and serve
    * a blog?
    * maybe some triggers for things that I can hit from mobile?

## Instructions
1) Follow [the instructions](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) for installing ubuntu server on raspberry pi
1) ssh to each box and set the same temporary password for ubuntu (i.e., a password you won't use much later. Feel free to make it strong, though, you'll basically never have to type it, as passwordless sudo is on
1) `cd scripts && TEMP_PASSWORD=yourtemppassword ./setup_key_ssh.sh`

## Shutcuts, Techdebt, and security TODOs
* Chose to use passwordless ssh (more secure) but sudo leave all (less secure)
* Add new user and remove ubuntu user; give new user same rights

## Automation i'd like to do
* Idea: make a little docker file with ansible in it to do more of this initial setup jazz.
    * Install the snap
    * add the alias for kubectl on the server
    * add an alias for helm on the server
    * setup the user (ubuntu for now) to be able to use kubectl (see [step 2](https://microk8s.io/docs))
    * set the hostnames for when I'm ssh'd in.
    * run the cgroup memory fix

## Build of Materials
### First purchase
To get started on this, I bought:
1) 4 Raspberry Pi 4Bs with 4gb ram
1) ~2 32gb sd cards, and 2 16 gb sd cards~ returned and replaced with 4 64gb MICRO sd cards, because I'm dumb.
1) ~4 micro-usb cables (a to micro b)~ 4 usb-c cables (a to usb c, power capable.) bloody, bloody hell I had to order these online I was tired of the hour round trips to microcenter.
1) a powered usb hub
1) a new ethernet switch

This came to ~$350.

(I do intend to buy a case, just figured I'd get it up and running first)
