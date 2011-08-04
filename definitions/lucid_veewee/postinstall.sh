#!/biin/bash -e

# most of this script taken from veewee, vagrant

export DEBIAN_FRONTEND="noninteractive"

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*

if [[ -z $1 ]]; then # STAGE 1: during veewee build, and copied to ~/ so stage 2 can be called during vagrant
  # vagrant ssh key
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  cat > ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF

  # update packages
  aptitude update
  aptitude upgrade -y
  aptitude clean

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

