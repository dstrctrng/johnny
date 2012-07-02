#!/bin/bash -e

if [[ ! -d "/vagrant" ]]; then exit 0; fi

cd /vagrant/provision

perl -pe 's{^(\s*Acquire::http::Proxy)}{#$1}' -i /etc/apt/apt.conf

aptitude hold linux-server linux-headers-server

if [[ ! -x "$(which bundle 2>&-)" ]]; then
  gem install 'bundler-1.1.3.gem'
fi
bundle check || bundle --local --path vendor/bundle

bundle exec chef-solo -c "config/solo.rb" -N localhost

export DEBIAN_FRONTEND=noninteractive

aptitude update
aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true mysql-client mysql-server memcached nginx bind9 tzdata

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

perl -pe 'm{bind-address} && s{127.0.0.1}{0.0.0.0}' -i /etc/mysql/my.cnf 
echo "update user set host='%' where host='$(hostname -s)'" | mysql -u root mysql
service mysql restart
