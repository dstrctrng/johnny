#!/bin/bash -e

umask 022

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

# install rvm
cat > /etc/apt/sources.list.d/rvm.conf <<EOF
deb http://173.203.93.136/apt/zendesk/lucid/production binary/
EOF

aptitude install -y openssl libreadline6 libreadline6-dev curl git-core zlib1g \
                    zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 \
                    libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev \
                    automake libtool bison subversion

aptitude update
aptitude install -y -o Aptitude::CmdLine::Ignore-Trust-Violations=true rvm rvm-ree201103 rvm-ree rvm-ruby rvm-jruby

# install mysql
aptitude install -y mysql-client mysql-server tzdata
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
