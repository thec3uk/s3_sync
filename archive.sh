#!/bin/bash

SOURCE=$1
LOCAL_ARCHIVE=$2

slack_hook () {
  # needs to be an ENV var outside of the script
  WEBHOOK_URL=https://hooks.slack.com/services/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
  EMOJI=:ghost:
  USERNAME=archive-bot
  CHANNEL=#alerts-archive
  curl -o /dev/null -s -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${USERNAME}\", \"text\": \"${1}\", \"icon_emoji\": \"${EMOJI}\"}" $WEBHOOK_URL
}

/sbin/mount_smbfs //admin:c3media@c3-streamer/Records $SOURCE
echo "Copying ${SOURCE} to ${LOCAL_ARCHIVE}" && \
    cp -r $SOURCE $LOCAL_ARCHIVE && \
    echo "Syncing ${LOCAL_ARCHIVE} to S3" && \
    /usr/local/bin/aws s3 sync --quiet $LOCAL_ARCHIVE s3://thec3-online-dump/


TEXT=$(df -h | grep Filesystem)
slack_hook $TEXT
TEXT=$(df -h | grep $2)
slack_hook $TEXT
