#!/bin/bash -ex

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

function badge() {
echo "[![$3](https://img.shields.io/badge/Status-$1-$2.svg?style=flat)](http://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME)"
}

export STATE_SHELVED=$(badge Shelved gray "Shelved")
export STATE_EXPERIMENTAL=$(badge Experimental_or_POC red "Experimental")
export STATE_ACTIVE=$(badge Active_Initial_Development orange "Active Development")
export STATE_PRE_ALPHA=$(badge Pre_Alpha yellow "Pre Alpha")
export STATE_ALPHA=$(badge Alpha yellowgreen "Alpha")
export STATE_BETA=$(badge Beta green "Beta")
export STATE_PROD=$(badge Production_Ready blue "Production Ready")

export BLURB=$(
cat <<EOF
-------

**If you use this project please consider giving us a star on [GitHub](http://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME). Also if you can spare 30 secs of your time please let us know your priorities here https://sillelien.wufoo.com/forms/zv51vc704q9ary/  - thanks, that really helps!**

Please contact us through chat or through GitHub Issues.

[![GitHub Issues](https://img.shields.io/github/issues/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.svg)](https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues).

[![Join the chat at https://gitter.im/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

-------

EOF
)

export FOOTER=$(
cat <<EOF
--------

[![GitHub License](https://img.shields.io/github/license/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.svg)](https://raw.githubusercontent.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/master/LICENSE)

(c) 2015 Sillelien all rights reserved. Please see [LICENSE](https://raw.githubusercontent.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/master/LICENSE) for license details of this project. Please visit http://sillelien.com for help and commercial support or raise issues on [GitHub](https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues).
EOF
)

export HEADER=""

export TUTUM="[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)"

envsubst '${RELEASE}:${BLURB}:${FOOTER}:${HEADER}:${STATE_SHELVED}:${STATE_EXPERIMENTAL}:${STATE_ACTIVE}:${STATE_PRE_ALPHA}:${STATE_ALPHA}:${STATE_BETA}:${STATE_PROD}:${TUTUM}' < README.md > /tmp/README.expanded
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
