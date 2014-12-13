#!bin/bash
# pyra multistrap config script
# this is run on the device at first boot

# configuration options
# this should be replaced by an interactive first-run-wizard later on.

hostname="pyra"

user_name="pyra"
user_pass="pyra"

root_pass="root"

########################################################################

# setup script


# environment

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
export LC_ALL=C LANGUAGE=C LANG=C

# stop dpkg from asking any questions, just uses the default settings for everything
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

touch /etc/fstab
mount -t sysfs sysfs /sys
mount -t proc proc /proc

# configure packages

# set up a few things manually
/var/lib/dpkg/info/dash.preinst install

dpkg --force-configure-any --configure base-passwd

# base-files will fail to install if there are any files in /var/run
rm /var/run/* -rf
dpkg --force-configure-any --configure base-files
dpkg --force-configure-any --configure dpkg
dpkg --force-configure-any --configure perl-base
dpkg --force-configure-any --configure debconf
dpkg --force-configure-any --configure apt

# apt can handle things from here

apt-get -f install

# used to be 
#dpkg --configure -a
# but apt handles things slightly better it seems.

#init got replaced by a link to this script, move the real one back
#rm /sbin/init
mv /sbin/init-real /sbin/init


###############################################################

# set up the rest of the system

# set root password
passwd "root" <<EOF
$root_pass
$root_pass
EOF

#create a normal user

adduser --gecos "" $user_name << EOF
$user_pass
$user_pass
EOF

adduser $user_name sudo

# set hostname
echo $hostname > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost $hostname" > /etc/hosts
hostname -F /etc/hostname

#enable serial login
systemctl enable serial-getty@ttyO2.service

# if kernel kernel modules weren't installed from a package
depmod -a 

# make sure everything is written to filesystem
sync

# reboot
#shutdown -rn now
reboot --force
