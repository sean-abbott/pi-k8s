# External DNS (Ansible Role)

This role will install coredns running to provide dns information for clients outside of this pi-k8s cluster

## Requirements

You'll need your k8s connection set up and working already. Probably.

## Role Variables

None so far

## Dependencies

* You'll need your cluster information to be available in the default kubernetes, or you'll need to explicitly add context to this role. (See https://docs.ansible.com/ansible/latest/collections/community/kubernetes/k8s_module.html#parameter-context)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
