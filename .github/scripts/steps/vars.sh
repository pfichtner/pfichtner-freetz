#!/usr/bin/env bash
set -euo pipefail

LINK="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
LAST="$(ls images/*.image | sed 's,.*/,,;s,\.image$,,')"
NAME="$(ls images/*.image | sed 's,.*/,,;s,_[0-9].*,,')"

echo "link=$LINK"
echo "last=$LAST"
echo "name=$NAME"
