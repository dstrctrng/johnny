#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then
  exit 0
fi

figlet "sync"
tmp_provision="$(mktemp -d -t XXXXXXXXX)"
rsync -ia /vagrant/provision/. "$tmp_provision"

figlet "bundling"
cd "$tmp_provision"
if [[ ! -x "$(which bundle 2>&-)" ]]; then
  gem install 'bundler-1.1.3.gem'
fi
bundle --local --path vendor/bundle

figlet "cook"
ln -nfs $tmp_provision/{nodes,roles,cookbooks,.microwave} ~/
bundle exec chef-solo -c "$tmp_provision/.microwave/config/solo.rb" -N localhost

figlet "clean"
rm -rf "$tmp_provision"
