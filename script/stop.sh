#!/bin/bash
# Stop the remote app server.

APP_PATH=/srv/app
HOST=mtpo

ssh "$HOST" "$APP_PATH/bin/mtpo stop"
