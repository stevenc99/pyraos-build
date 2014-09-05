#!/bin/bash

# should move to first-run-wizard eventualy

PYRA_HOSTNAME="pyra"
PYRA_USERNAME="pyra"
PYRA_PASSWORD="pyra"
PYRA_ROOTPASS="root"


DISTRO="debian"
#DISTRO=ubuntu


# temp repo untill the real one is set up.
PYRA_REPO="http://next.openpandora.org/repo"

# xfce image with some extra bits
PYRA_PACKAGES="pyra-meta-xfce pyra-meta-extra"


if [[ $DISTRO == "debian" ]]
then

	# debian
	SUITE="testing"
	MIRROR="http://ftp.nl.debian.org/debian"
	COMPONENTS="main,contrib,non-free"
elif [[ $DISTRO == "ubuntu" ]]
then
	# ubuntu
	SUITE="trusty"
	MIRROR="http://ports.ubuntu.com/ubuntu-ports"
	COMPONENTS="main,universe,multiverse,restricted"
else
	echo "Unknown distro."
	exit
fi

TARGET="rootfs-"$DISTRO"-"$SUITE


# eatmydata disables calls to sync/fsync, which speeds things up a lot
# especially when running apt-get install inside the chroot.

eatmydata debootstrap --arch armhf --include=eatmydata --components=$COMPONENTS $SUITE $TARGET $MIRROR


###############################################################################
# generate the conf.sh script that's run inside the chroot.

cat > $TARGET/conf.sh << END_CONF
#!/bin/bash

# stop dpkg from asking any questions, just uses the default settings for everything

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# add the pyra repo to the sources
echo deb $PYRA_REPO $SUITE/ > /etc/apt/sources.list.d/pyra.list
apt-get update

# install the rest through the meta packages
eatmydata apt-get --force-yes -y install $PYRA_PACKAGES

apt-get clean

#enable serial login

if [[ $DISTRO == "ubuntu" ]]
then
	echo "start on stopped rc RUNLEVEL=[2345]" >  /etc/init/serial.conf
	echo "stop on runlevel [!2345]"            >> /etc/init/serial.conf
	echo " "                                   >> /etc/init/serial.conf
	echo "respawn"                             >> /etc/init/serial.conf
	echo "exec /sbin/getty 115200 ttyO2"       >> /etc/init/serial.conf
elif [[ $DISTRO == "debian" ]]
then
	systemctl enable serial-getty@ttyO2.service
fi

# set root password
passwd "root" <<EOF
$PYRA_ROOTPASS
$PYRA_ROOTPASS
EOF

#create a normal user
# --gecos "" stops it from asking too many questions

adduser --gecos "" $PYRA_USERNAME << EOF
$PYRA_PASSWORD
$PYRA_PASSWORD
EOF

# add user to the sudo group
adduser $PYRA_USERNAME sudo

# set hostname
echo $PYRA_HOSTNAME > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost $hostname" > /etc/hosts
hostname -F /etc/hostname

END_CONF
###############################################################################

# now jump into the chroot and run the script

chroot $TARGET /bin/bash conf.sh

# remove the config script
rm $TARGET/conf.sh

