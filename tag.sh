#!/bin/bash -ex


cd $(dirname $0)
DIR=$(pwd)
cd -

export CODENAME=$($DIR/codenames/name.sh $CIRCLE_SHA1)

git push --set-upstream origin master
git tag ${CODENAME}-${CIRCLE_BUILD_NUM} || :
git push --tags
git push origin master
