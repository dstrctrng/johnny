#!/bin/bash -e

figlet "hack"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

figlet "sync"
tmp_provision="$(mktemp -d -t XXXXXXXXX)"
rsync -ia /vagrant/provision/. "$tmp_provision"

figlet "bundling"
cd "$tmp_provision"
bundle --local --path vendor/bundle

figlet "cook"
ln -nfs "$tmp_provision"/{nodes,roles,cookbooks,config,.microwave} ~/
bundle exec chef-solo -c config/solo.rb -N localhost

figlet "info"
pwd
id -a
uname -a
env

figlet "clean"
cd
rm -rf "$tmp_provision"
