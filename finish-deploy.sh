#!/usr/bin/env bash
cp README.staged.md README.md
git add README.md
git config --global user.email "hello@neilellis.me"
git config --global user.name "Neil Ellis"
git pull
git commit -am "Release completion step for $(cat .release) [skip ci]" || :
git push origin master
