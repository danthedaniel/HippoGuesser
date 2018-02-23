#!/bin/bash
# Start the remote app server.

PORT=1337
APP_PATH=/srv/app
HOST=mtpo

ssh "$HOST" "PORT=$PORT $APP_PATH/bin/mtpo start"
