#!/bin/bash
CHANNEL_ID=
CHENNEL_SECRET=
APP_NAME=rumors-line-bot

token=$(curl -v -X POST https://api.line.me/v2/oauth/accessToken \
-H "Content-Type:application/x-www-form-urlencoded" \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id='$CHANNEL_ID'' \
--data-urlencode 'client_secret='$CHENNEL_SECRET'' | jq -r '.access_token')

heroku config:set LINE_CHANNEL_TOKEN=$token -a $APP_NAME