#!/bin/bash

WEEDMASTER=localhost:9333
REPLICATION=001
DIR=/home/ubuntu/image
MONGODB=localhost:27005/image
#IDKEY=_id
IDKEY=id

if [ ! -d $DIR ]; then
	echo "$DIR does not exist"
	exit 1
fi

find $DIR -type f -iregex '.*\.png' | 
# head -n 1 | # seaweedfs start
while read FILENAME; do

	# log
	echo "uploading $FILENAME" >&2

	# seaweedfs 
	ANSWER=$(curl -s -X POST "http://$WEEDMASTER/dir/assign?replication=$REPLICATION" 2>&1)
	read FID PUBLICURL < <(echo "var r = $ANSWER; console.log(r.fid + ' ' + r.publicUrl);" | nodejs)
	curl -s -X PUT -F file=@"$FILENAME" http://$PUBLICURL/$FID > /dev/null

#	if [ $DIR/$FID.png != "$FILENAME" ]; then
#		mv "$FILENAME" $DIR/$FID.png
#	fi

	# mongodb
	echo "db.figure.insert({'$IDKEY':'$FID', 'src': '$FILENAME'})"

done | mongo $MONGODB --quiet > /dev/null
