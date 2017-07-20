#!/usr/bin/env bash
cp README.staged.md README.md
git commit -m "Release completion step for $(cat .release) [skip ci]" || :
git push origin master
