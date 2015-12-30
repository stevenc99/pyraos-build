#!/bin/sh

#exit 0

NOW=$(date +"%Y-%m-%d_%H-%M")
cd $1
mkdir -p ../export
#FNAME=$(basename $1)-$NOW.tgz
FNAME=$(basename $1)
echo Creating ${FNAME}.tgz

if hash pv 2>/dev/null
then
	SIZE=$(du -sb . | awk '{print $1}')
	tar cf - .  | pv -s $SIZE | gzip --rsyncable > ../export/${FNAME}.tgz
else
	tar cf - .  | gzip --rsyncable > ../export/${FNAME}.tgz
fi

#echo Creating ${FNAME}.tar.xz
#tar cf - . | pv -s $SIZE | xz --block-size=16M > ../export/${FNAME}.tar.xz

cd ../export/
sha256sum ${FNAME}.tgz > ${FNAME}.tgz.sha256
#sha256sum ${FNAME}.tar.xz > ${FNAME}.tar.xz.sha256
#ln -sf ${FNAME} $(basename $1)-latest.tgz

rm $1 -rf
