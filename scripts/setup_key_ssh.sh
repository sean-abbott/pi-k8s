#!/usr/bin/env bash
set -euo pipefail

SSH_PUBLIC_KEY_FILE=${SSH_PUBLIC_KEY_FILE:-"${HOME}/.ssh/id_rsa.pub"}
TEMP_PASSWORD=${TEMP_PASSWORD:-""}

if [ -z "$SSH_PUBLIC_KEY_FILE" ] || [ -z "$TEMP_PASSWORD" ]; then
    echo "make sure you set SSH_PUBLIC_KEY and TEMP_PASSWORD before running"
    exit 1
fi

if [ ! -f "${SSH_PUBLIC_KEY_FILE}" ]; then
    echo "no file found at $SSH_PUBLIC_KEY_FILE. set SSH_PUBLIC_KEY_FILE environment variable to work"
    exit 1
fi

cat << SCRIPT > /tmp/disable_password_ssh.sh
#!/usr/bin/env bash
set -ueo pipefail

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d).bak
sed -i \
	-e 's/PasswordAuthentication yes/PasswordAuthentication no/' \
	-e 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' \
	/etc/ssh/sshd_config
systemctl restart ssh
SCRIPT

while read -r node; do
    # remove any existing copies of the key
    ssh-keygen -R "$node"
    # accept the host key
    ssh-keyscan -H "$node" >> ~/.ssh/known_hosts
    sshpass -p "$TEMP_PASSWORD" ssh-copy-id -i "$SSH_PUBLIC_KEY_FILE" "ubuntu@${node}"
    scp /tmp/disable_password_ssh.sh "ubuntu@${node}":/tmp
    ssh -T "ubuntu@${node}" <<- CMD
    chmod +x /tmp/disable_password_ssh.sh
    sudo /tmp/disable_password_ssh.sh
CMD
done < nodelist.txt
