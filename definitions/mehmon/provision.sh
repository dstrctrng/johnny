#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then exit 0; fi

perl -pe 's{^(\s*Acquire::http::Proxy)}{#$1}' -i /etc/apt/apt.conf

cd /vagrant/provision
bundle check || bundle --local --path vendor/bundle
bundle exec chef-solo -c "config/solo.rb" -N localhost
