#!/bin/bash -e

umask 022

# proxy
export http_proxy="http://$(echo $SSH_CONNECTION | cut -d= -f2 | awk '{print $1}'):3128"

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# update packages
aptitude update
aptitude search -F '%c %p' linux-image-[0123456789] | grep ^i | awk '{print $2}' | cut -d- -f3- | sed 's#^#linux-headers-#' | xargs aptitude install -q -y rsync wget curl
aptitude hold linux-server linux-headers-server 
aptitude clean

# ssh key
mkdir -p ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
