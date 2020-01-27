#!/bin/bash
HEROKU_API_KEY=
CHANNEL_ID=
CHANNEL_SECRET=
APP_NAME=rumors-line-bot

token=$(curl -v -X POST https://api.line.me/v2/oauth/accessToken \
-H "Content-Type:application/x-www-form-urlencoded" \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id='$CHANNEL_ID'' \
--data-urlencode 'client_secret='$CHANNEL_SECRET'' | jq -r '.access_token')

# heroku config:set LINE_CHANNEL_TOKEN=$token -a $APP_NAME
curl -n -X PATCH https://api.heroku.com/apps/$APP_NAME/config-vars \
  -d '{
  "LINE_CHANNEL_TOKEN": "'$token'"
}' \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3" \
  -H "Authorization: Bearer $HEROKU_API_KEY"
