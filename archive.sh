#!/bin/bash

SOURCE=$1
LOCAL_ARCHIVE=$2
MUSER=$3
MPASS=$4
HOOK=$5

slack_hook () {
  EMOJI=:ghost:
  USERNAME=archive-bot
  CHANNEL=#alerts-archive
   curl -o /dev/null -s -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${USERNAME}\", \"text\": \"${1}\", \"icon_emoji\": \"${EMOJI}\"}" "$2"
}

mount_volumes () {
  mkdir -p /media/archive/
  mkdir -p /media/vmix/
  mount /dev/vg1/lv1 /media/archive/
  mount -t cifs //mediaserver01/vmix /media/vmix/ -o user=$1 -o pass=$2
}

# mount_volumes $MUSER $MPASS
echo "Copying ${SOURCE} to ${LOCAL_ARCHIVE}" && \
    rsync -a --exclude=Windows10Upgrade --exclude='$RECYCLE.BIN' --exclude='System Volume Information' $SOURCE $LOCAL_ARCHIVE && \
    echo "Syncing ${LOCAL_ARCHIVE} to S3" && \
    /usr/bin/aws s3 sync --quiet $LOCAL_ARCHIVE s3://thec3-online-dump/


TEXT=$(df -h | grep Filesystem)
slack_hook "${TEXT}" "${HOOK}"
TEXT=$(df -h | grep $2)
slack_hook "${TEXT}" "$HOOK"

exit 0
