#!/usr/bin/env bash
set -eux
if [[ ${CIRCLE_BRANCH:-dev} != 'master' ]] ; then
 mvn -e -q versions:set -DnewVersion=$(cat .release)
 mvn -q versions:resolve-ranges
 mvn -q versions:lock-snapshots
fi 
