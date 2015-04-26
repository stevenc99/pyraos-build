multistrap -f pyra-xfce.conf

# Move image into image-dir
echo Moving image into the public directory...
NOW=$(date +"%Y-%m-%d_%H-%M")
mv ./pyra-debian-jessie-xfce-rootfs.tgz /srv/www/vhosts/pyra-handheld.com/domains/packages.pyra-handheld.com/httpdocs/rootfs/pyra-debian-jessie-xfce-rootfs-$NOW.tgz
