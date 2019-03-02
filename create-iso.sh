#!/bin/bash

set -euo pipefail

loc=$(dirname "$(readlink -f "$0")")
cur=$(pwd)
perm="$(id -u):$(id -g)"
iso="/tmp/ubuntu.iso"
version="18.10"
srcdir=$(mktemp -d)
dstdir=$(mktemp -d)

if [ ! -f "$iso" ]
then
	printf "# Downloading Ubuntu server ISO\n"
	wget  --no-verbose --show-progress "http://cdimage.ubuntu.com/releases/${version}/release/ubuntu-${version}-server-amd64.iso" -O $iso
else
	printf "# ISO already exists -> skipping download\n"
fi

printf "# Mounting\n"
sudo mount -t iso9660 -o loop $iso $srcdir

printf "# Copying ISO files...\n"
sudo cp -R $srcdir/* $dstdir/.
sudo cp -R $srcdir/.disk $dstdir/.

printf "# Copying custom settings\n"
sudo cp -R $loc/custom $dstdir/.

printf "# Setting ISO\n"
cd $dstdir

sudo sed -i "s/^ui gfxboot bootlogo/#ui gfxboot bootlogo/" isolinux/isolinux.cfg
#sudo sed -i "s/^include menu.cfg/#include menu.cfg/" isolinux/isolinux.cfg	# !!!! THIS WILL BREAK BOOT
sudo tee isolinux/txt.cfg <<EOF
default install
label install
  menu label ^Install Custom Ubuntu -- ERASE ALL DATA
  kernel /install/vmlinuz
  append  vga=788 initrd=/install/initrd.gz file=/cdrom/custom/ubuntu.seed debconf/priority=critical locale=en_US console-setup/ask_detect=false console-setup/layoutcode=cz netcfg/choose_interface=auto net.ifnames=0 biosdevname=0 ---

label check
  menu label ^Check disc for defects
  kernel /install/vmlinuz
  append   MENU=/bin/cdrom-checker-menu vga=788 initrd=/install/initrd.gz quiet ---

label memtest
  menu label Test ^memory
  kernel /install/mt86plus

label hd
  menu label ^Boot from first hard disk
  localboot 0x80
EOF

printf "# Creating custom ISO file\n"
#sudo mkisofs -o ubuntu-custom.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Ubuntu 16.04 Custom ISO" .
sudo mkisofs -o ../ubuntu-custom.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -cache-inodes -J -l -r -V "Ubuntu $version Custom ISO" .

printf "# Fix ISO boot\n"
sudo isohybrid ../ubuntu-custom.iso

printf "# Moving ISO file\n"
sudo mv ../ubuntu-custom.iso $cur/ubuntu-custom.iso
sudo chown $perm $cur/ubuntu-custom.iso

printf "# Cleaning\n"
sudo umount $srcdir
sudo rm -r $srcdir
sudo rm -r $dstdir
