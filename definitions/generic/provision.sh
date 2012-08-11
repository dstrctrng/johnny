#!/bin/bash -e

umask 022

export DEBIAN_FRONTEND=noninteractive

# update packages
aptitude update
aptitude upgrade -q -y

# install ruby
aptitude install -y ruby rubygems ruby-dev libopenssl-ruby

gem install rubygems-update
cd /var/lib/gems/1.8/gems/rubygems-update-*
ruby setup.rb
gem install bundler

# aptitude cleanup
aptitude clean

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*

# microwave
cd /vagrant/provision
bundle check || bundle --local --path vendor/bundle
bundle exec chef-solo -c "config/solo.rb" -N localhost
