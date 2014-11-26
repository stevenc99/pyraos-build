#!/bin/bash
# Script to clone / update GITs according to a text-file
# and build Debian-Packages from them as well as sort them into the repository
# 2014-10-27 V1.1 by Michael Mrozek (EvilDragon)
#

# Setup some Env-Vars

builddir="/srv/www/vhosts/pyra-handheld.com/domains/packages.pyra-handheld.com/build"
gitlist="/srv/www/vhosts/pyra-handheld.com/domains/packages.pyra-handheld.com/build/packages.txt"
repodir="/srv/www/vhosts/pyra-handheld.com/domains/packages.pyra-handheld.com/httpdocs/debian"
logdir="/srv/www/vhosts/pyra-handheld.com/domains/packages.pyra-handheld.com/httpdocs/buildlogs"

# Update rootfs if needed
ARCH=armhf DIST=testing git-pbuilder update

# Package-Build-Loop
while read file
do
  url=""
  update=false
  build=false
  gitdir=""
  name=""
  package=""

  if [ ! $file = "" ]; then

	cd "$builddir"

 	url="$(echo $file)"

 	# Clean old stuff
 	rm -R "$builddir/tmp/"
	mkdir "$builddir/tmp"
	build=false

  	# Read the GIT URL
  	gitdir="$(echo ${url%.*} | awk -F'/' '{print $NF}')"

  	# Does GIT exist?
  	if [ ! -d "$builddir/$gitdir" ]; then
    		# Clone it!
    		echo New Package! - Cloning $url
    		gbp-clone $url 
    		build=true
  	else
    		# Otherwise: Update the GIT.
    		echo Update GIT
    		# Check if the package needs to be rebuilt
		cd "$builddir/$gitdir"
    		update="$(gbp-pull | grep "up to date")"
    		if [ -n "$update" ]; then
			echo No update - building package not needed.
      			build=false
    		else
			echo Package will be updated!
      			build=true
    		fi
  	fi

  	# Build if Package is updated

  	if [ "$build" == true ]; then

    	# Get package name
    	package="$(head -1 "${builddir}/${gitdir}/debian/control" | awk '{print $NF}')"

     	echo Building Package: $package

     	# Build the source and binary packages!
     	cd "$builddir/$gitdir"
     	git-buildpackage --git-ignore-new

     	echo Putting package into repository.

     	# Put it into the repository

     	cd "$builddir/tmp"
     	name="$(ls *.changes)"
     	reprepro --ignore=missingfile -V -b "$repodir" include jessie-pyra $name

     	# Move the build log files into the build-log-dir
     	mv "$builddir"/tmp/*.build "$logdir"

  	fi
  fi

done <$gitlist
