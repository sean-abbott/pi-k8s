# pi-k8s
A journey with raspberry pis and k8s. See the [journal](journal/day_00.md) for daily decisions and what not.
[Say hi](https://github.com/sean-abbott/pi-k8s/issues/1) if you drop by!

I'm intending to try and make everything that I do accessible from here, minus any secrets that I use. This repository is probably going to be ugly, because this is just the learning process for now. Maybe I'll clean up later, but home projects don't tend to last to clean up phase with me.

## Intentions
I don't think I'm being too ambitious with this righ tnow.

* Learn me some k8s
* do NOT devolve into lots of sysadmin or trying to make this perfectly replicable
* Run plex
* run multiarchitecture, use affinity to run a cups server on my x86 box with the attached printer
* ~run a household wiki~ ✓
    * maybe (https://wiki.js.org/)? ✓
    * this manifest has the basics of getting nfs-client-provisioner to work ✓
* ~run an internal dns server to make things easier to access~ ✓
* run openFaaS and get some triggers based on the world. Temperature. That sort of thing. Maybe later get another pi and use it to water things.
* run a local ca, maybe using [step ca](https://github.com/smallstep/autocert)


## longer stretch goals
* make this publicly accessible and serve
    * oh. This. I'll need this https://github.com/inlets/inlets "inlets combines a reverse proxy and websocket tunnels to expose your internal and development endpoints to the public Internet via an exit-node. An exit-node may be a 5-10 USD VPS or any other computer with an IPv4 IP address."
    * a blog? maybe gatsby?
    * maybe some triggers for things that I can hit from mobile?


## Instructions
### RPi
These were made by following an [ubuntu tutorial](https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi)
1) Follow [the instructions](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) for installing ubuntu server on raspberry pi
1) ssh to each box and set the same temporary password for ubuntu (i.e., a password you won't use much later. Feel free to make it strong, though, you'll basically never have to type it, as passwordless sudo is on
1) `cd scripts && TEMP_PASSWORD=yourtemppassword ./setup_key_ssh.sh`
1) ssh to each box, and 
    1) edit `/boot/firmware/cmdline.txt` to be `net.ifnames=0 dwc_otg.lpm_enable=0 console=serial0,115200 cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc`. Note that this is only necessary for raspberry pi's. I think if i add an x86 or atom or whatever later, this won't be necessary.
    1) Run `sudo usermod -a -G microk8s ubuntu && sudo chown -f -R ubuntu ~/.kube` on each box.
    1) Reboot
1) do the [server and leaf nodes bit](https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#5-master-node-and-leaf-nodes) Make sure you notice that you have to run add-node each time on the server, and then join on the workers.

### x86
1) install ubuntu server. This has the option to automatically set up passwordless ssh, yes please.
1) You DO need to set up passwordless sudo. on the box, run `sudo EDITOR=vi visudo -f /etc/sudoers.d/01-k8s-users` and paste in:
   ```
   # Allow members of group sudo to execute any command
   %sudo	ALL=(ALL:ALL) NOPASSWD: ALL
   ```
1) Run `sudo usermod -a -G microk8s ubuntu && sudo chown -f -R ubuntu ~/.kube` on each box.
1) Exit and come back, make sure passwordless sudo works and you can run `microk8s status`
1) do the [server and leaf nodes bit](https://ubuntu.com/tutorials/how-to-kubernetes-cluster-on-raspberry-pi#5-master-node-and-leaf-nodes) Make sure you notice that you have to run add-node each time on the server, and then join on the workers.

### Near term TODO to make sure mixed architecture is working:
**Note: all affinities are "or find a mixed arch repo**
1) Update etcd operator and etcd to have affinity for ARM
1) Update postgres to have an affinity for arm
1) update nfs-client-provisioner to have an affinity for arm
1) double check everything else; there may be others

## Application / useful thing instructions
### metallb
1) change router to have a slightly larger network /23 instead of /24
1) ensure router's dhcp setup is the same (only giving the network to the original /24)
1) enable metallb, using an ip range from the other /24 that the router knows about

### dashboard
* just enable the add-on. See [howtos](HOWTO.md) for details of access.

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
1) `cd manifests/external-dns` (we're now working from the manifests/external-dns directory)
1) add the namespace: `kubectl apply -f ns.yaml`
1) apply the coredns chart: `helm install ext-coredns --values coredns-values.yaml stable/coredns -n dns` (make sure you edit it for local values around the etc parameters), 
    ```
      - name: etcd
    parameters: example.com
      stubzones
      path /skydns
      endpoint http://etcd-client.etcd.svc.cluster.local:2379
    ```
1) apply the coredns loadbalancer manifest: `kubectl apply -f coredns-loadbalancer.yaml`
1) apply the external dns manifest. We're using an outdated version for now, because the external-dns team hasn't gotten around to arm64: `kubectl apply -f external-dns.yaml`
1) Finally, show off! Get a test service running: `kubectl apply -f external-dns-validator.yaml` (this sets up a loadbalancer service with the annotations you'll need, make sure to update example.com to your domain name)
1) For me, I ended up setting the coredns IP made by the coredns-loadbalancer in my router so I get it by default for my network.
1) see the howtos for how to add a non-kubernetes name into etcd for coredns

### Ingress (with ability to set dns names)
1) in manifests/ingress, `kubectl apply -f ns.yaml`
1) Apply the helm chart `helm install ingress stable/nginx-ingress --values values.yaml  -n ingress`
1) Check to make sure you got an IP for the service (`kubectl -n ingress describe service -l app=nginx-ingress` should show an appropriate external ip from your metallb setup)
1) apply the `kubectly apply -f test-ingress.yaml`. This should give you a hostname you can resolve at your external dns server above (i.e. `dig @<your dns service ip> test-ingress.my.example.com`). However, note that there are two steps that take awhile here. First, external-dns take a minute or two to pick this up, and THEN dns can take a minute or two. Watch the external-dns logs (`kubectl -n kube-system logs  -l app=external-dns`) to see this happen. Note that it won't happen, I think, until the service is available.
1) remove the test `kubectl delete -f test-ingress.yam`

### nfs-client-provisioner
This'll get you persistent volumes for anything you need persistence from. Like databases.
1) First you need to create an nfs share. That's on you. I'm using my ancient synology nas (128mbs of ram, baby!) and it's working fine.
1) then you'll need to install nfs-client on each of your nodes. I actually finally started doing ansible for this. I'm gonna leave running ansible outside the bounds of this for now.
1) install the helm chart: `helm install nfs-provisioner --values values.yaml --set nfs.server=x.x.x.x stable/nfs-client-provisioner -n nfs`
1) test it. `kubectl apply -f test-claim.yaml; kubectl apply test-pods.yaml` and you should see a text show up in a folder that should be obvious in your nfs 
1) remove the tests `kubectl delete -f test-claim.yaml test-pod.yaml.`  Note that the nfs client provisioner only archives the folders, it doesn't delete them. This may be a thing to figure out later


### wiki
1) create the namespace `kubectl apply -f ns.yaml`
1) create the postgres persistent volume claim: `kubectl apply -f postgres-pvc.yaml`
1) create the postgres configmap `kubectl applyf -f postgres-configmap.yaml`
1) create the postgres deployment `kubectl apply -f postgres-deployment.yaml`
1) (see howtos for verification of postgres)
1) create the wiki `kubectl apply -f wikijs.yaml` (supposedly a chart is "coming soon")
1) verify it (see [bash_aliases](sugar_files/home_.bash_aliases)) for port forwarding. Feel free to set up the admin user and stuff
1) add the wikijs service (which is an ingress, which should get you your hostname in external dns as well)
1) test it by doing to the dns name! woot!  (see the ingress ntoes about how long the dns names take to add and resolve; it can be like 10 minutes, so chill unless you see an error)

## near future todos
* set up registry, replace any distribution stuff with registry (or set up dockerhub account and get arm64 builds going on for anything I need)
* maybe local storage via usb, since sd cards are supposed to not love it. Would actually be used for anything more volatile; registry, microk8s local storage, etc. Maybe even update things so /var (that snap runs out of) is on usb instead of sd card

## Shutcuts, Techdebt, and security TODOs
* Chose to use passwordless ssh (more secure) but leave sudo all (less secure)
* Add new user and remove ubuntu user; give new user same rights
* setup the bitnami secrets thing so I can stop masking things in this repo
* nginx ingress controller default backend is in an endless crash backoff loop. fix that.
* wiki/postgres: if I have to recreate this, I will need to do it with the nfs-v3 shares, which is not current annotated 'cause it's still "just working" since it doesn't have to change permissions on an existing volume. (this is after the nfsv4/v3 kerfluffle)
* wiki: figure out how to populate the ssh key and storage (backup) configuration for the wiki when it starts.

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
* nfs-client provisioner only "archives" "volumes", so might need to make it delete them or manually delete them
* add enough confit to wikijs that I don't have to do admin setup

## Food for thought
* https://www.jeffgeerling.com/blog/2020/uasp-makes-raspberry-pi-4-disk-io-50-faster
* https://www.reddit.com/r/kubernetes/comments/hkvww4/sinker_a_tool_to_sync_all_of_your_kubernetes/
* cdk8s

## Notes
* pi based multi-arch images: https://github.com/raspbernetes/multi-arch-images
* OMG yes please: https://www.botkube.io  (monitoring of event for FREEEEEEE)

## Build of Materials
### First purchase
To get started on this, I bought:
1) 4 Raspberry Pi 4Bs with 4gb ram
1) ~2 32gb sd cards, and 2 16 gb sd cards~ returned and replaced with 4 64gb MICRO sd cards, because I'm dumb.
1) ~4 micro-usb cables (a to micro b)~ 4 usb-c cables (a to usb c, power capable.) bloody, bloody hell I had to order these online I was tired of the hour round trips to microcenter.
1) a powered usb hub
1) a new ethernet switch

This came to ~$350.

### Second purchase
Bought the 6 pi version of [the bramble case from c4labs](https://www.c4labs.com/product/zebra-bramble-case-raspberry-pi-3-b-color-and-stack-options/). Hasn't shown up yet. Total of $45 with taxes.

### Third purchase
1) 2 more RPis
1) 2 more 64gb  sd cards
1) 2 more usb-c cables

~ $155 more

### Total monetary cost
Ha ha, time, tho
~$555
