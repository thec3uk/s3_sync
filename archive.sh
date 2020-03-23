#!/bin/bash

SOURCE=$1
LOCAL_ARCHIVE=$2
MUSER=$3
MPASS=$4

slack_hook () {
  # needs to be an ENV var outside of the script
  # WEBHOOK_URL=https://hooks.slack.com/services/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
  EMOJI=:ghost:
  USERNAME=archive-bot
  CHANNEL=#alerts-archive
  curl -o /dev/null -s -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${USERNAME}\", \"text\": \"${1}\", \"icon_emoji\": \"${EMOJI}\"}" $WEBHOOK_URL
}

mount_volumes () {
  mkdir -p /media/archive/
  mkdir -p /media/vmix/
  mount /dev/vg1/lv1 /media/archive/
  mount -t cifs //mediaserver01/vmix /media/vmix/ -o user=$1 -o pass=$2
}

mount_volumes $MUSER $MPASS
echo "Copying ${SOURCE} to ${LOCAL_ARCHIVE}" && \
    rsync -a --exclude=Windows10Upgrade --exclude='$RECYCLE.BIN' --exclude='System Volume Information' $SOURCE $LOCAL_ARCHIVE && \
    echo "Syncing ${LOCAL_ARCHIVE} to S3" && \
    /usr/local/bin/aws s3 sync --quiet $LOCAL_ARCHIVE s3://thec3-online-dump/


TEXT=$(df -h | grep Filesystem)
slack_hook $TEXT
TEXT=$(df -h | grep $2)
slack_hook $TEXT
