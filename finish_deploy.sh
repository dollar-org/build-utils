#!/usr/bin/env bash
cp README.staged.md README.md
git commit -m "[skip ci] Release Completion ${RELEASE}  [${RELEASE_NUMBER:-}/${RELEASE_ID:-}] (${CODENAME})" || :
git push origin master
