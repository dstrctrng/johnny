#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then exit 0; fi

cd /vagrant/provision

#perl -pe 's{^(\s*Acquire::http::Proxy)}{#$1}' -i /etc/apt/apt.conf

aptitude hold linux-server linux-headers-server

if [[ ! -x "$(which bundle 2>&-)" ]]; then
  gem install 'bundler-1.1.3.gem'
fi
bundle check || bundle --local --path vendor/bundle

bundle exec chef-solo -c "config/solo.rb" -N localhost
