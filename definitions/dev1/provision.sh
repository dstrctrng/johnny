#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then exit 0; fi

cd /vagrant/provision

if [[ ! -x "$(which bundle 2>&-)" ]]; then
  gem install 'bundler-1.1.3.gem'
fi
bundle check || bundle --local --path vendor/bundle

bundle exec chef-solo -c "config/solo.rb" -N localhost

export DEBIAN_FRONTEND=noninteractive

aptitude update
aptitude install -y mysql-client mysql-server memcached nginx bind9

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
