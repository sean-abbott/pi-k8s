# Ansible assitance for pi-k8s

I use these ansible roles and an inventory (local) to run stuff. This makes it more repeatable.

## Setup
1) `pipx install ansible`
1) `pipx runpip install openshift` # the ansible k8s libraries use this file


## Known Issues
* The `snap` ansible module does not correctly update channels, so as of now you'd have to completely reset the cluster to upgrade microk8s.
