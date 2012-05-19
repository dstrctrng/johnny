#!/bin/bash -e

# proxy
export http_proxy="http://$(echo $SSH_CONNECTION | cut -d= -f2 | awk '{print $1}'):3128"

aptitude install -y build-essential

# install ruby
aptitude install -y ruby rubygems ruby-dev libopenssl-ruby
gem install rubygems-update -v 1.8.17
cd /var/lib/gems/1.8/gems/rubygems-update-1.8.17
ruby setup.rb
gem uninstall rubygems-update -x -a || true

# vbox guest additions
ver_virtualbox="$(cat .vbox_version)"
url_guestadditions="http://download.virtualbox.org/virtualbox/$ver_virtualbox/VBoxGuestAdditions_$ver_virtualbox.iso"
pth_guestadditions="$HOME/VBoxGuestAdditions_$ver_virtualbox.iso"
wget -nv -O "$pth_guestadditions" "$url_guestadditions"
mount -o loop "$pth_guestadditions" /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f "$pth_guestadditions"

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*
