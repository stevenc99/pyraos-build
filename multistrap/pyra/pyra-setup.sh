#!/bin/bash

# multistrap setup script, run by multistrap after generating the image, $1 points to the image root


# make sure fstab exists
touch $1/etc/fstab

# some evil bits to launch the setup script at first boot
# this is undone by the config script

mv $1/sbin/init $1/sbin/init-real
ln -s ../pyra-config.sh $1/sbin/init
