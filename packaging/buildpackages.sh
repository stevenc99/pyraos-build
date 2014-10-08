#!/bin/bash
# Script to clone / update GITs according to a text-file
# and build Debian-Packages from them as well as sort them into the repository
# 2014-10-08 V1 by Michael Mrozek (EvilDragon)
#

# Setup some Env-Vars

builddir="/srv/www/vhosts/domains/packages.pyra-handheld.com/build"
gitlist="/srv/www/vhosts/domains/packages.pyra-handheld.com/build/packages.txt"
repodir="/srv/www/vhosts/domains/packages.pyra-handheld.com/httpdocs/debian"
logdir="/srv/www/vhosts/domains/packages.pyra-handheld.com/httpdocs/buildlogs"

# Package-Build-Loop
while read file          
do           

  url="$(echo $file | awk '{print $1}')"
  branch="$(echo $file | awk '{print $2}')"
  
  # Clean old stuff
  rm "$builddir/*.build"
  rm "$builddir/*.changes"
  rm "$builddir/*.dsc"
  rm "$builddir/*.deb"
  rm "$builddir/*.diff.gz"
  rm "$builddir/*.tar.*"
  build=false
  
  # Read the GIT URL
  gitdir="$(echo ${url%.*} | awk -F'/' '{print $NF}')"
  
  # Does GIT exist?
  if [ ! -d "$builddir/$gitdir" ]; then
    # Clone it!
    echo New Package! - Cloning $url
    git clone $url 
    build=true
  else
    # Otherwise: Update the GIT.
    echo Update GIT
    cd "$builddir/$gitdir"
    git fetch
    
    # Change to the specified branch
    git checkout $branch
    
    # Check if the package needs to be rebuilt
    update="$(git rebase origin | grep "is up to date")"
    if [ -n "$update" ]; then
      build=false
    else
      build=true
    fi
  fi  
  
  # Build if Package is updated
  
  if [ "$build" == true ]; then
  
    # Get package name
    package="$(head -1 "${builddir}/${gitdir}/debian/control" | awk '{print $NF}')"
  
     # Build the source and binary packages!
     cd "$builddir/$gitdir"
     sbuild -d jessie-pyra -c jessie-armhf --arch=armhf --arch-all --source
 
     # Put it into the repository
 
     cd "$builddir"
     name="$(ls *.changes)"
     reprepro -V -b "$repodir" include jessie-pyra $name
    
     # Move the build log files into the build-log-dir
     mv "$builddir/*.build" "$logdir/"
    
  fi

done <$gitlist