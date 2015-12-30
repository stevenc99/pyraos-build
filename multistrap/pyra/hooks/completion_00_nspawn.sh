#!/bin/sh

# run config script if building on arm hardware,
# otherwise it'll be run on the first boot.

if [ "$(uname -m)" = "armv7l" ]
then
	systemd-nspawn -D $1 /pyra-config.sh
	rm $1/pyra-config.sh
	# new ssh keys will need to be made on the real device
	rm $1/etc/ssh/ssh_host_*
fi

