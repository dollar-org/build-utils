#!/bin/sh -eux
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"
git reset HEAD --hard
git clean -fd
git checkout master
git pull
git merge staging -m "Auto merge"
git push
git commit -a -m "Promotion from staging" || :
git tag ${RELEASE} || :
git push --tags
git push origin master
