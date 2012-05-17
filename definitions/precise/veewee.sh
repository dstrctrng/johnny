#!/bin/bash -e

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"
export http_proxy="http://$(echo $SSH_CONNECTION | cut -d= -f2 | awk '{print $1}'):3128"

# update packages
if [[ -z $(grep multiverse /etc/apt/sources.list) ]]; then
  sed -i s/universe/"universe multiverse"/ /etc/apt/sources.list
fi
aptitude install -q -y figlet
aptitude update
aptitude install -q -y wget rsync
aptitude search -F '%c %p' linux-image-[0123456789] | grep ^i | awk '{print $2}' | cut -d- -f3- | sed 's#^#linux-headers-#' | xargs aptitude install -q -y
aptitude install -q -y ruby rubygems 
aptitude upgrade -y
aptitude clean
