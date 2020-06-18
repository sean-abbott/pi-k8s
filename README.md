# pi-k8s
A journey with raspberry pis and k8s. See the [journal](journal/day_0.md) for daily decisions and what not.
[Say hi](https://github.com/sean-abbott/pi-k8s/issues/1) if you drop by!

I'm intending to try and make everything that I do accessible from here, minus any secrets that I use. This repository is probably going to be ugly, because this is just the learning process for now. Maybe I'll clean up later, but home projects don't tend to last to clean up phase with me.

## Intentions
I don't think I'm being too ambitious with this righ tnow.

* Learn me some k8s
* do NOT devolve into lots of sysadmin or trying to make this perfectly replicable
* Run plex
* run multiarchitecture, use affinity to run a cups server on my x86 box with the attached printer
* run a household wiki
    * maybe (https://wiki.js.org/)?
* run an internal dns server to make things easier to access
* run openFaaS and get some triggers based on the world. Temperature. That sort of thing. Maybe later get another pi and use it to water things.


## longer stretch goals
* make this publicly accessible and serve
    * oh. This. I'll need this https://github.com/inlets/inlets "inlets combines a reverse proxy and websocket tunnels to expose your internal and development endpoints to the public Internet via an exit-node. An exit-node may be a 5-10 USD VPS or any other computer with an IPv4 IP address."
    * a blog? maybe gatsby?
    * maybe some triggers for things that I can hit from mobile?


## Instructions
These were made by following an [ubuntu tutorial](https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi)
1) Follow [the instructions](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) for installing ubuntu server on raspberry pi
1) ssh to each box and set the same temporary password for ubuntu (i.e., a password you won't use much later. Feel free to make it strong, though, you'll basically never have to type it, as passwordless sudo is on
1) `cd scripts && TEMP_PASSWORD=yourtemppassword ./setup_key_ssh.sh`
1) ssh to each box, and 
    1) edit `/boot/firmware/cmdline.txt` to be `net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc`. Note that this is only necessary for raspberry pi's. I think if i add an x86 or atom or whatever later, this won't be necessary.
    1) Run `sudo usermod -a -G microk8s ubuntu && sudo chown -f -R ubuntu ~/.kube` on each box.
    1) Reboot
1) do the [server and leaf nodes bit](https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#5-master-node-and-leaf-nodes) Make sure you notice that you have to run add-node each time on the server, and then join on the workers.

### metallb
1) change router to have a slightly larger network /23 instead of /24
1) ensure router's dhcp setup is the same (only giving the network to the original /24)
1) enable metallb, using an ip range from the other /24 that the router knows about

### dashboard
# just enable the add-on. See [howtos](HOWTO.md) for details of access.

### external-dns (coredns)
1) `microk8s enable helm3 dns` (the etcd operator expects clusterdns)
1) `microk8s kubectl -n kube-system edit configmap/coredns` and replace the dns servers with `1.1.1.1 1.0.0.1` to use cloudflare instead of google.
1) add an alias in bash_aliases. I just did `alias helm=microk8s helm3`
1) :sad_trombone: need to get local images and a value overlay and the default chart looks unsupported as of now
1) ok, to build etcd operator locally:
    1) install go and docker (`sudo apt install golang docker.io`)
    1) `mkdir -p ~/go/{bin,src}`
    1) `cd ~/go/src && git clone git@github.com:sean-abbott/etcd-operator.git'` find a fedora replacement, so these instructions are already out of date. FML. Also, note that this encompasses edits to the etcd operator where I just hacked it to default to the etcd image I created. There is either a bug with the operator or with the helm chart, such that the repository setting from the chart doesn't make it into the etcd configuration in the operator, and I'm probably not gonna take the time to find out which. What I may do, at some point, is take the time to set up a dockerhub repo for the etcd container I built, which basically just takes the existing ARM64 etcd image and adds the necessary environment variable to make it run on arm. 
    1) Install go dep with `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`. Yeah, I hate it to. I may be missing something here, as well.
    1) `PATH=$PATH:~/go/bin` you should also add this to your bashrc
    1) `cd ~/go/src/etcd-operator && ./hack/update_vendor.sh` (this requires dep and will install all the golang dependencies)
    1) `sudo usermod -a -G docker ubuntu` (next time your reboot you won't need to `sudo` to use docker
    1) you could probably use the overall build script, but instead, I did `./hack/build/operator/build`, `./hack/build/backup-operator/build` and `./hack/build/restore-operator/build`, which puts output in ./_output, which is where docker expects it
    1) `sudo docker build -t local-etcd-operator -f hack/build/Dockerfile .` to build the docker file; need to look into autobuilds for docker hub
    1) Save the docker image as a tar file: `docker save etcd_operator:0.9.4_arm64 > etcd_operator.tar`
    1) distribute the tar file to all your arm nodes
    1) on each node, `microk8s ctr image import /tmp/etcd_operator.tar`
    1) Grab the docker directory of this repo, cd into it, `docker build -t localetcd .` All this is doing is using the available arm64 etcd image, but stuffing in the environment variable that the arm64 image requires but doesn't include.
    1) `docker tag localetcd etcd:v3.4.9` this is required because this is what the operator now will use
    1) do the docker save, distribute, and import we did above
1) initialize a helm chart repository `helm repo add stable https://kubernetes-charts.storage.googleapis.com/`
1) run `helm repo update`
1) helm3's syntax is slightly different than helm as listed in the coredns example: `helm install etcd-op stable/etcd-operator -f chart_overrides.yaml -n etcd`
1) `kubectl apply -f etcd-cluster.yaml` You should now have a cluster. congrats!  See [HOWTO.md](HOWTO.md) for how to use / verify it's working.

## near future todos
* set up registry, replace any distribution stuff with registry (or set up dockerhub account and get arm64 builds going on for anything I need)
* nfs setup for some persistent storage
* maybe local storage via usb, since sd cards are supposed to not love it. Would actually be used for anything more volatile; registry, microk8s local storage, etc. Maybe even update things so /var (that snap runs out of) is on usb instead of sd card

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
* automate arm64 builds of the etcd operator
    * https://github.com/estesp/manifest-tool  this is used with docker hub to do multi-arch images. An [example usage](https://github.com/rook/rook/blob/master/build/release/Makefile#L179)

## Notes
* pi based multi-arch images: https://github.com/raspbernetes/multi-arch-images

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

