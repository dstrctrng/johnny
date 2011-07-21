#!/biin/bash -e

# most of this script taken from veewee, vagrant

if [[ -z $1 ]]; then # STAGE 1: during veewee build, and copied to ~/ so stage 2 can be called during vagrant
  # vagrant ssh key
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  cp vagrant.pub ~/.ssh/authorized_keys

  # update packages
  aptitude update
  aptitude upgrade -y
  aptitude clean

  # udev cleanup
  rm -f /etc/udev/rules.d/70-persistent-net.rules
  mkdir -p /etc/udev/rules.d/70-persistent-net.rules
  rm -rf /dev/.udev/
  rm -f /lib/udev/rules.d/75-persistent-net-generator.rules

  # dhcp cleanup
  rm /var/lib/dhcp3/*

  # dhcp delays
  echo "pre-up sleep 2" >> /etc/network/interfaces
else # STAGE 2: during vagrant after rebooting into updated kernel

  # build requirements for virtual box guest additions
  aptitude install -y build-essential wget linux-headers-$(uname -r)

  VBOX_VERSION=$(cat ~/.vbox_version)
  pth_vguest=$(mktemp)
  wget -O $pth_vguest http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
  mount -o loop $pth_vguest /mnt
  sh /mnt/VBoxLinuxAdditions.run
  umount /mnt

  rm $pth_vguest
fi
