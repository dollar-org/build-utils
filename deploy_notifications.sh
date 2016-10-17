#!/usr/bin/env bash

cd $(dirname $0)
DIR=$(pwd)
cd -

. $DIR/functions.sh

. env.sh

env_type="Dev"
GITLOG=$(git log -1 HEAD --pretty=format:%s)

if  [[ ${CI_BRANCH} == "master" ]]
then
    env_type="Live"
fi

${BUILD_UTILS_DIR}/raygun/deployment.sh -v "${RELEASE}" -t "$RAYGUN_EXTERNAL_TOKEN" -a "$RAYGUN_API_KEY"  -e "neil@vizz.buzz" -g "${CI_SHA1}" "Branch: ${CI_BRANCH} Project ${CI_PROJECT_REPONAME} Changes: $CI_COMPARE_URL Log: ${GITLOG}"

DATE_TODAY=$(date +"%Y-%m-%d")

curl --data "key=${RESCUE_TIME_KEY}&highlight_date=$DATE_TODAY&description=${CI_PROJECT_REPONAME}+${CI_BRANCH}+${RELEASE}&source=${env_type}+Deployment" https://www.rescuetime.com/anapi/highlights_post
#
curl  -X POST -H "Content-type: application/json" -d "{\"title\":\"${CI_PROJECT_REPONAME} deployed ${RELEASE} for ${CI_BRANCH} \",\"text\":\"${CI_PROJECT_REPONAME} deployed ${RELEASE} for ${CI_BRANCH}, please see $CI_COMPARE_URL\",\"tags\":[\"${CI_PROJECT_REPONAME}\",\"${CI_BRANCH}\",\"${RELEASE}\"],\"alert_type\":\"info\"}" "https://app.datadoghq.com/api/v1/events?api_key=${DATADOG_API_KEY}"

curl -d "apiKey=30d3924e3694ac68c5743ba00e4bf0aa&appVersion=${RELEASE}" https://notify.bugsnag.com/deploy

curl https://sentry.io/api/hooks/release/builtin/106345/8a24068e454450b1689a71197893e46720dc007836a718af0edd29a7b2194d9f/ \
  -X POST \
  -H 'Content-Type: application/json' \
  -d "{\"version\": \"${RELEASE}\"}"

