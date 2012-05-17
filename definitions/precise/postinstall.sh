#!/biin/bash -e

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# vagrant ssh key
install -v -d -m 0700 ~/.ssh
cat > ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF

# update packages
aptitude install -q -y figlet
figlet "packages"
if [[ -z $(grep multiverse /etc/apt/sources.list) ]]; then
  sed -i s/universe/"universe multiverse"/ /etc/apt/sources.list
fi

aptitude update
aptitude install -q -y wget rsync
aptitude upgrade -y
aptitude search -F '%c %p'  linux-image-[0123456789] | grep ^i | awk '{print $2}' | cut -d- -f3- | sed 's#^#linux-headers-#' | xargs aptitude install -q -y
aptitude clean

# upgrade rubygems
figlet "rubygems"
aptitude install -q -y ruby rubygems 
gem install rubygems-update -v 1.8.17
cd /var/lib/gems/1.8/gems/rubygems-update-1.8.17
ruby setup.rb
gem uninstall rubygems-update -x -a || true
gem install bundler -v 1.1.3

figlet "cleaning"
# package cleanup
aptitude clean

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*
