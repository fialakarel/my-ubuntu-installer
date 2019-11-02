#!/bin/bash

set -v

## ## ## ## ## ## ## ## ## ## ## ## ## ##
##                                     ##
## First startup setup in progres ...  ##
##                                     ##
## ## ## ## ## ## ## ## ## ## ## ## ## ##

# Get IP
# Template for netplan
cat >/etc/netplan/01-netcfg.yaml <<EOF
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
EOF

# Activate networking
netplan apply

## Recompress filesystem
#btrfs filesystem defragment -r -clzo /

# Trim FS
fstrim --verbose --all

# Get my latest install steps
git clone https://github.com/fialakarel/my-ubuntu-install-steps /tmp/my-ubuntu-install-steps

# Execute install steps
cd /tmp/my-ubuntu-install-steps
bash install.sh

# Cleaning
rm -rf /tmp/my-ubuntu-install-steps
