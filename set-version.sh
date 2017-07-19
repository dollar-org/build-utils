#!/usr/bin/env bash
set -eux
[[ ${CIRCLE_BRANCH:-dev} != 'master' ]] || ( mvn -e versions:set -DnewVersion=$(cat .release) && mvn versions:resolve-ranges && mvn versions:lock-snapshots )
