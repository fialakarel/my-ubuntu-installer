#!/bin/bash

set -v

## ## ## ## ## ## ## ## ## ## ## ## ## ##
##                                     ##
## First startup setup in progres ...  ##
##                                     ##
## ## ## ## ## ## ## ## ## ## ## ## ## ##

# Get IP
dhclient eth0

# Recompress filesystem
btrfs filesystem defragment -r -clzo /

# Trim FS
fstrim --verbose --all

# Get my latest install steps
git clone https://github.com/fialakarel/my-ubuntu-install-steps /tmp/my-ubuntu-install-steps

# Execute install steps
cd /tmp/my-ubuntu-install-steps
bash install.sh

# Cleaning
rm -rf /tmp/my-ubuntu-install-steps
