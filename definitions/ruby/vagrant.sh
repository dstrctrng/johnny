#!/bin/bash -e

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

# install mysql
aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true mysql-client mysql-server tzdata
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
perl -pe 'm{bind-address} && s{127.0.0.1}{0.0.0.0}' -i /etc/mysql/my.cnf 
echo "update user set host='%' where host='$(hostname -s)'" | mysql -u root mysql
service mysql restart

# install other daemons
aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true memcached nginx bind9

# aptitude cleanup
aptitude clean

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*
