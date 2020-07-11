pi-prereqs
=========

Pre-requisites for raspberry-pi4bs to join a microk8s cluster

Requirements
------------

passwordless ssh, and passwordless sudo. The latter should be setup already, the former will need setting up. See [scripts](../../../scripts/README.md) if necessary.

Role Variables
--------------

N/A

Dependencies
------------

N/A

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
         - { role: pi-prereqs }

Author Information
------------------

Sean is probably gonna play war thunder later.
