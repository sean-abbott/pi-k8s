# Why scripts?

Because I'm trying to make this super lightweight and not require any extra tools. Also because I"m trying to not do ANYTHING with this.
That said, you still need to `sudo apt install sshpass`, or type in your password n times

*NOTE: THIS script is not terribly secure, in that it assumes you can accept the host keys for sure. Probably fine on a home network, though*

These scripts should be idempotent


# How to run ...

## setup_ssh_key.sh
1) install sshpass
1) create a file with a newline separated list of nodes called "nodelist.txt". this is git ignored
1) run `SSH_PUBLIC_KEY_FILE="/path/to/.ssh/id_rsa.pub" TEMP_PASSWORD=neverusedagain ./setup_key_ssh.sh` (note that SSH_PUBLIC_KEY_FILE will assume `~/.ssh/id_rsa.pub` if you don't specify.)
