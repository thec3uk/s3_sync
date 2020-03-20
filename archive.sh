#!/bin/bash

SOURCE=$1
LOCAL_ARCHIVE=$2
WEBHOOK_URL=https://hooks.slack.com/services/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
EMOJI=:ghost:
USERNAME=archive-bot
CHANNEL=#alerts-archive

mount_smbfs //admin:c3media@c3-streamer/Records $1 && \
    cp -r $1 $2 && \
    aws s3 sync --quiet $2 s3://thec3-online-dump/

TEXT=$(df -h | grep $2)
curl -o /dev/null -s -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${USERNAME}\", \"text\": \"${TEXT}\", \"icon_emoji\": \"${EMOJI}\"}" $WEBHOOK_URL 
