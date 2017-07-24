#!/usr/bin/env bash
set -eux
. functions.sh
CODENAME_1=$(codenames/name.sh 1234567890123456 arcane_jobs)
CODENAME_2=$(codenames/name.sh 1234567890123456 names)
CODENAME_3=$(codenames/name.sh 1234567890123456 shortwords)
[[ $CODENAME_1 == "victorious-carnifex-of-trent_vale" ]]
[[ $CODENAME_2 == "toinette-nicholas-nessim" ]]
[[ $CODENAME_3 == "purely-gleety-barre" ]]
