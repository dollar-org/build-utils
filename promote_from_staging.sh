#!/bin/sh -ex

if [ -n "$GIT_EMAIL" ]
then
  email=$GIT_EMAIL
  name=$GIT_NAME
else
  email=$DOCKER_EMAIL
  name=$DOCKER_USER
fi

set -u

git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"
git reset HEAD --hard
git clean -fd
envsubst '${RELEASE}' < README.md > /tmp/README.expanded
git checkout master
git pull 
git merge staging -m "Auto merge"
echo ${RELEASE} > .release
mv /tmp/README.expanded README.md
git commit -a -m "Promotion from staging of ${RELEASE}" || :
git push
git tag ${RELEASE} || :
git push --tags
git push origin master
