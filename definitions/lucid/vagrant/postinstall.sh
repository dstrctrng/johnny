#!/bin/bash -e

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*

# build requirements for virtual box guest additions
aptitude install -y build-essential wget linux-headers-$(uname -r)

tmp_vguest=$(mktemp -t XXXXXXXXX)

VBOX_VERSION=$(cat ~/.vbox_version)
wget -O $tmp_vguest http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

mount -o loop $tmp_vguest /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm $tmp_vguest

# update OS packages
if [[ -z $(grep multiverse /etc/apt/sources.list) ]]; then
  sed -i s/universe/"universe multiverse"/ /etc/apt/sources.list
fi

# relocation large dirs to /data
install -d -o root -g root -m 0755 /data/home

[[ -L /home ]] || {
  rsync -a /home/ /data/home/
  rm -r /home
  ln -s /data/home /
}

[[ -L /var/chef ]] || {
  rm -rf /var/chef
  ln -nsf /data/zendesk_chef /var/chef
}

# grant sudo permissions
cat > /etc/sudoers <<EOF
Defaults env_reset
root ALL=(ALL) ALL
zendesk ALL=(ALL) NOPASSWD:ALL
EOF

chmod 440 /etc/sudoers

aptitude update -q
aptitude full-upgrade -q -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true
aptitude install -y rsync figlet -o Aptitude::CmdLine::Ignore-Trust-Violations=true

# install build packages
figlet "ruby requirements"
aptitude install -q -y build-essential autoconf bison curl git-core -o Aptitude::CmdLine::Ignore-Trust-Violations=true
aptitude install -q -y libreadline5 libreadline5-dev zlib1g zlib1g-dev openssl libssl-dev libsqlite3-0 sqlite3 libsqlite3-dev libxml2-dev libsasl2-dev libxslt-dev -o Aptitude::CmdLine::Ignore-Trust-Violations=true

# install rvm
figlet "rvm"
install -d -o root -g root -m 0755  /usr/local/bin
tmp_rvm=$(mktemp -t XXXXXXXXX)
wget --no-check-certificate https://github.com/zendesk/rvm/raw/master/contrib/install-system-wide -O $tmp_rvm
bash $tmp_rvm
rm -f $tmp_rvm
install -d -o root -g root -m 0755  /usr/local/bin

# source rvm, use ree
rm -f /etc/profile.d/rvm.sh
touch /etc/profile.d/rvm.sh
for a in /root/.bashrc; do
  touch $a
  echo "[[ -f /usr/local/lib/rvm ]] && source /usr/local/lib/rvm" >> $a
  echo "rvm ree" >> $a
done

# rvm ops, don't mess with error handling
export RUBY_GC_MALLOC_LIMIT=60000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_HEAP_MIN_SLOTS=500000
export RUBY_HEAP_SLOTS_INCREMENT=1

want_187="2011.03"
want_192="p180"

set +e
source /usr/local/lib/rvm

ncpus=$(grep -c "^processor" /proc/cpuinfo)
export rvm_make_flags="-j ${ncpus}"

rvm list strings | grep -q "ree-1.8.7-$want_187" || rvm install ree-1.8.7-$want_187
rvm list strings | grep -q "ruby-1.9.2-$want_192" || rvm install ruby-1.9.2-$want_192

# upgrade ruby 1.9.2 rubygems
#rvm ruby-1.9.2-$want_192
#rvm rubygems 1.6.2 # this is the default, here to document

# upgrade ree rubygems
rvm ree-1.8.7-$want_187
rvm rubygems 1.5.3

# some global gems
rvm exec gem install bundler -v1.0.21

# make system ruby the default, here for documentation
rvm system --default

set -e
