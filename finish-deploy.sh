#!/usr/bin/env bash
cp README.staged.md README.md
git commit -m "[skip ci] Release completion step for $(cat .release)" || :
git push origin master
