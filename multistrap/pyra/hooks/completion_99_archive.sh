#!/bin/sh

#exit 0

NOW=$(date +"%Y-%m-%d_%H-%M")
cd $1
mkdir -p ../export
#FNAME=$(basename $1)-$NOW.tgz
FNAME=$(basename $1)
[ -n "$SOURCE_DATE_EPOCH" ] && FNAME="${FNAME}-${SOURCE_DATE_EPOCH}-stage1"
echo Creating ${FNAME}.tgz

if [ -n "$SOURCE_DATE_EPOCH" ]; then
	# See https://wiki.debian.org/ReproducibleBuilds/TimestampsInTarball
	find . -newermt "@$SOURCE_DATE_EPOCH" -print0 \
	 | xargs -0r touch --no-dereference --date="@$SOURCE_DATE_EPOCH"
fi

if hash pv 2>/dev/null
then
	SIZE=$(du -sb . | awk '{print $1}')
	PV="pv -s $SIZE"
else
	PV="cat"
fi

# Create tarball with files sorted in a stable order, see
# https://wiki.debian.org/ReproducibleBuilds/FileOrderInTarballs
# and without timestamp in the gzip header, see
# https://wiki.debian.org/ReproducibleBuilds/TimestampsInGzipHeaders
find . -print0 \
 | LC_ALL=C sort -z \
 | tar --no-recursion --null -T - -cf - \
 | $PV \
 | gzip -n --best --rsyncable \
 > ../export/${FNAME}.tgz

#echo Creating ${FNAME}.tar.xz
#tar cf - . | pv -s $SIZE | xz --block-size=16M > ../export/${FNAME}.tar.xz

cd ../export/
sha256sum ${FNAME}.tgz > ${FNAME}.tgz.sha256
#sha256sum ${FNAME}.tar.xz > ${FNAME}.tar.xz.sha256
#ln -sf ${FNAME} $(basename $1)-latest.tgz

rm $1 -rf
