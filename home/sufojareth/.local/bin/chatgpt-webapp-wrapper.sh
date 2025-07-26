#!/bin/bash

URL="$1"

# ChatGPT app settings
CHATGPT_DOMAIN="chatgpt.com"
CHATGPT_PROFILE="/home/sufojareth/.local/share/org.gnome.Epiphany.WebApp_495265260f5b6d5b9ea08470124be963c86f8b47"
CHATGPT_URL="https://chatgpt.com/"

# If no URL provided or it matches the ChatGPT domain, open in Epiphany WebApp
if [[ -z "$URL" ]] || [[ "$URL" == *"$CHATGPT_DOMAIN"* ]]; then
    exec epiphany --application-mode "--profile=$CHATGPT_PROFILE" "$CHATGPT_URL"
else
    exec firefox "$URL"
fi
