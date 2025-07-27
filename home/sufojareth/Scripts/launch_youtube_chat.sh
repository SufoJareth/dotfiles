#!/bin/bash

API_KEY="AIzaSyDRBbRtkOfLmQiGZ0E0GGA8WmhnMlX4SUc"
CHANNEL_ID="UCwLZPxbVRrBKWenpG-G9BNA"

# Query the YouTube Data API for live broadcasts
VIDEO_ID=$(curl -s \
  "https://www.googleapis.com/youtube/v3/search?part=id&channelId=${CHANNEL_ID}&eventType=live&type=video&key=${API_KEY}" \
  | jq -r '.items[0].id.videoId')

if [[ -z "$VIDEO_ID" || "$VIDEO_ID" == "null" ]]; then
  kdialog --error "No livestream is currently active for @geno421"
  exit 1
fi

CHAT_URL="https://www.youtube.com/live_chat?v=${VIDEO_ID}&is_popout=1"

# Launch using known-good Epiphany Web App profile
epiphany --application-mode "--profile=/home/sufojareth/.local/share/org.gnome.Epiphany.WebApp_youtubechat" "$CHAT_URL"
