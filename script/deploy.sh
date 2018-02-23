#!/bin/bash
# Deploy MTPO to production.

PORT=1337
APP_PATH=/srv/app
HOST=mtpo

TAR_PATH=$(ls -1rt `find rel/mtpo -maxdepth 1 -type f` | tail -n 1)
scp "$TAR_PATH" "$HOST":"$APP_PATH"

# When someone reads this and judges me for not just piping in a script to stdin
# on the server, I'd like to let them know that any failed commands were causing
# the script to end prematurely. "set -e" was not involved. I don't care if some
# of the commands fail (like if the server isn't running and I try to stop it).
ssh "$HOST" "$APP_PATH/bin/mtpo stop"
ssh "$HOST" "cd $APP_PATH && rm -rf bin erts* lib releases var"
ssh "$HOST" "cd $APP_PATH && tar -xvf prod*.tar.gz"
ssh "$HOST" "cd $APP_PATH && rm prod*.tar.gz"
ssh "$HOST" "cd $APP_PATH && PORT=$PORT bin/mtpo start"
