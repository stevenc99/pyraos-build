#!/bin/bash

# multistrap setup script, run by multistrap after generating the image, $1 points to the image root


# make sure fstab exists

touch $1/etc/fstab

mkdir $1/boot/extlinux
echo "menu title Pyra boot SD" >> $1/boot/extlinux/extlinux.conf
echo "timeout 50"  >> $1/boot/extlinux/extlinux.conf
echo "default none"  >> $1/boot/extlinux/extlinux.conf
echo " " >>  $1/boot/extlinux/extlinux.conf

# some evil bits to launch the setup script at first boot
# this is undone by the config script

mv $1/sbin/init $1/sbin/init-real
ln -s ../pyra-config.sh $1/sbin/init

#systemd-nspawn -D $1 /pyra-config.sh
#rm $1/pyra-config.sh
