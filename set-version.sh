#!/usr/bin/env bash
set -eux
[[ ${CIRCLE_BRANCH:-dev} != 'master' ]] || ( mvn -eq versions:set -DnewVersion=$(cat .release) && mvn -q versions:resolve-ranges && mvn -q versions:lock-snapshots )
