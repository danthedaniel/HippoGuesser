#!/bin/bash
# Deploy MTPO to production.

tar_path=`find rel/mtpo -maxdepth 1 | head -n 2 | tail -n 1`
scp "$tar_path" mumble:/srv/app
ssh mumble 'bash -s' < script/remote.sh
