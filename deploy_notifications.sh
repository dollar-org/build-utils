#!/usr/bin/env bash

cd $(dirname $0)
DIR=$(pwd)
cd -

. $DIR/functions.sh

. env.sh

env_type="Dev"
GITLOG=$(git log -1 HEAD --pretty=format:%s)

if [[ ${CIRCLE_BRANCH} == "staging" ]] || [[ ${CIRCLE_BRANCH} == "master" ]]
then
    env_type="Live"
fi

${BUILD_UTILS_DIR}/raygun/deployment.sh -v "${RELEASE}" -t "$RAYGUN_EXTERNAL_TOKEN" -a "$RAYGUN_API_KEY"  -e "neil@vizz.buzz" -g "${CIRCLE_SHA1}" "Branch: ${CIRCLE_BRANCH} Project ${CIRCLE_PROJECT_REPONAME} Changes: $CIRCLE_COMPARE_URL Log: ${GITLOG}"

DATE_TODAY=$(date +"%Y-%m-%d")

curl --data "key=${RESCUE_TIME_KEY}&highlight_date=$DATE_TODAY&description=${CIRCLE_PROJECT_REPONAME}+${CIRCLE_BRANCH}+${RELEASE}&source=${env_type}+Deployment" https://www.rescuetime.com/anapi/highlights_post

curl  -X POST -H "Content-type: application/json" -d "{\"title\":\"${CIRCLE_PROJECT_REPONAME} deployed ${RELEASE} for ${CIRCLE_BRANCH} \",\"text\":\"${CIRCLE_PROJECT_REPONAME} deployed ${RELEASE} for ${CIRCLE_BRANCH}, please see $CIRCLE_COMPARE_URL\",\"tags\":[\"${CIRCLE_PROJECT_REPONAME}\",\"${CIRCLE_BRANCH}\",\"${RELEASE}\"],\"alert_type\":\"info\"}" "https://app.datadoghq.com/api/v1/events?api_key=${DATADOG_API_KEY}"

