#!/bin/bash -e

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# update packages
if [[ -z $(grep multiverse /etc/apt/sources.list) ]]; then
  sed -i s/universe/"universe multiverse"/ /etc/apt/sources.list
fi
aptitude install -q -y figlet

figlet "packages"
aptitude update
aptitude install -q -y wget rsync
aptitude search -F '%c %p' linux-image-[0123456789] | grep ^i | awk '{print $2}' | cut -d- -f3- | sed 's#^#linux-headers-#' | xargs aptitude install -q -y

# install bundler
figlet "ruby, bundler"
aptitude install -q -y ruby rubygems 
gem install bundler -v 1.1.3

figlet "upgrade"
aptitude upgrade -y

# package cleanup
figlet "cleaning"
aptitude clean
