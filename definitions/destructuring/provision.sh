#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then exit 0; fi

cd /vagrant/provision

figlet "bundling"
if [[ ! -x "$(which bundle 2>&-)" ]]; then
  gem install 'bundler-1.1.3.gem'
fi
bundle --local --path vendor/bundle

figlet "cook"
bundle exec chef-solo -c "config/solo.rb" -N localhost
