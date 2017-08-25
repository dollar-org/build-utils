#!/usr/bin/env bash
set -eux
git pull
cp README.staged.md README.md
git add README.md
git config --global user.email "hello@neilellis.me"
git config --global user.name "Neil Ellis"
github_changelog_generator  --token=${GITHUB_CHANGELOG_TOKEN} --release-branch master --future-release ${NEXT_MAJOR_VERSION}
git add CHANGELOG.md
git commit -am "✔ Release completion step for $(cat .release) [skip ci]" || :
git push origin master
