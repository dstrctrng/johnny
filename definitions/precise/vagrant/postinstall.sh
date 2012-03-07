#!/bin/bash -e

nm_instance=$1; shift

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# identity
echo "127.0.0.1 localhost $nm_instance" > /etc/hosts
echo $nm_instance > /etc/hostname
hostname $nm_instance

# access
cat /vagrant/.ssh_authorized_keys >> ~/.ssh/authorized_keys

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*

# grant sudo permissions
cat > /etc/sudoers <<EOF
Defaults env_reset
root ALL=(ALL) ALL
EOF

chmod 440 /etc/sudoers
