#!/bin/bash -ex


cd $(dirname $0)
DIR=$(pwd)
cd -

. $DIR/functions.sh

git push --set-upstream origin master
git tag ${CODENAME}-${CI_BUILD_NUM} || :
git push --tags
git push origin master
