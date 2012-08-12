#!/bin/bash -e

umask 022

export DEBIAN_FRONTEND=noninteractive

# install avahi for zeroconf (bonjour)
aptitude install -y avahi-daemon
