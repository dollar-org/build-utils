#!/usr/bin/env bash
curl -X POST --header "Content-Type: application/json" -d '{ }' https://circleci.com/api/v1.1/project/gh/sillelien/$1?circle-token=$2
