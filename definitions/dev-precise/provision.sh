#!/bin/bash -e

figlet "hack"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

figlet "bundler"
gem install bundler -v 1.1.3

tmp_provision="$(mktemp -d -t XXXXXXXXX)"

rsync -ia /vagrant/provision/. "$tmp_provision"

figlet "bundling"
cd "$tmp_provision"
bundle --local --path vendor/bundle

figlet "info"
pwd
id -a
uname -a
env

cd
rm -rf "$tmp_provision"
