#!/bin/sh

# REQUIRED FIELDS - Today's date and commit message

MESSAGE=$(git log -1 HEAD --pretty=format:%s)
DATE_TODAY=$(date +"%Y-%m-%d")

# You can edit the LABEL value if you would rather
# describe these commits differently.

LABEL="$1"

# See more filtering examples in README.md

if [[ ${#MESSAGE} -gt 16 ]]; then
  curl --data "key=${RESCUE_TIME_KEY}&highlight_date=$DATE_TODAY&description=$MESSAGE&source=$LABEL" https://www.rescuetime.com/anapi/highlights_post
fi
