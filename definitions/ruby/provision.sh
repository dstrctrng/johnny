#!/bin/bash -e

cd /vagrant/provision
bundle check || bundle --local --path vendor/bundle
bundle exec chef-solo -c "config/solo.rb" -N localhost

export DEBIAN_FRONTEND=noninteractive

aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true memcached nginx bind9

aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true mysql-client mysql-server tzdata
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
perl -pe 'm{bind-address} && s{127.0.0.1}{0.0.0.0}' -i /etc/mysql/my.cnf 
echo "update user set host='%' where host='$(hostname -s)'" | mysql -u root mysql
service mysql restart
