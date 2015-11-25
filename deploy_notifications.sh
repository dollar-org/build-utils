#!/usr/bin/env bash
. env.sh

env_type="Dev"
GITLOG=$(git log -1 HEAD --pretty=format:%s)

if [[ ${CIRCLE_BRANCH} == "staging" ]] || [[ ${CIRCLE_BRANCH} == "master" ]]
then
    env_type="Live"
fi

${BUILD_UTILS_DIR}/raygun/deployment.sh -v "$(cat .release)" -t "$RAYGUN_EXTERNAL_TOKEN" -a "$RAYGUN_API_KEY"  -e "neil@vizz.buzz" -g "${CIRCLE_SHA1}" "Branch: ${CIRCLE_BRANCH} Project ${CIRCLE_PROJECT_REPONAME} Changes: $CIRCLE_COMPARE_URL Log: ${GITLOG}"

DATE_TODAY=$(date +"%Y-%m-%d")

curl --data "key=${RESCUE_TIME_KEY}&highlight_date=$DATE_TODAY&description=${CIRCLE_PROJECT_REPONAME}+${CIRCLE_BRANCH}+$(cat .release)&source=${env_type}+Deployment" https://www.rescuetime.com/anapi/highlights_post

curl --data https://zapier.com/engine/rss/131598/datadog/

curl -v -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -X POST \
        -d "{\"project\":\"${CIRCLE_PROJECT_REPONAME}\",\"branch\":\"${CIRCLE_BRANCH}\",\"release\":\"$(cat .release)\"}" \
        https://zapier.com/engine/rss/131598/datadog/
