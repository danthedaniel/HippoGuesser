#!/bin/bash
# Prepare MTPO for deployment to production.

cd assets
brunch build --production
cd ..
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix compile
MIX_ENV=prod mix release

mkdir -p rel/mtpo
timestamp=`date +%Y-%m-%d-%H%M`
tar_path=../../../../rel/mtpo/prod"$timestamp".tar.gz
cd _build/prod/rel/mtpo
tar czf "$tar_path" ./
