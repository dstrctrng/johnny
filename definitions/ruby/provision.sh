#!/bin/bash -e

umask 022

cd /vagrant/provision
bundle check || bundle --local --path vendor/bundle
bundle exec chef-solo -c "config/solo.rb" -N localhost
