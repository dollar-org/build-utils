#!/bin/bash -ex


cd $(dirname $0)
DIR=$(pwd)
cd -

. $DIR/functions.sh

[[ -f env.sh ]] && . env.sh

export CI_BRANCH=${CI_BRANCH:-${CIRCLE_BRANCH}}
export CI_BUILD_NUM=${CI_BUILD_NUM:-${CIRCLE_BUILD_NUM}}
export CI_PROJECT_USERNAME=${CI_PROJECT_USERNAME:-${CIRCLE_PROJECT_USERNAME}}
export CI_PROJECT_REPONAME=${CI_PROJECT_REPONAME:-${CIRCLE_PROJECT_REPONAME}}

export CODENAME=$($DIR/codenames/name.sh $CI_SHA1)
if [[ ${CI_BRANCH} == "staging" ]]
then
    export RELEASE=${RELEASE:-${CI_BUILD_NUM}}
    export TAG=${RELEASE:-${CI_BUILD_NUM}}
else
    export RELEASE=${RELEASE:-${CI_BRANCH}}
    export TAG=${RELEASE:-${CI_BUILD_NUM}}
fi

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
echo "[![$3](https://img.shields.io/badge/Status-$1-$2.svg?style=flat)](http://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME)"
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

**If you use this project please consider giving us a star on [GitHub](http://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME). A

Please contact us through chat or through GitHub Issues.

[![GitHub Issues](https://img.shields.io/github/issues/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME.svg)](https://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/issues)

[![Join the chat at https://gitter.im/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

-------

EOF
)

export FOOTER=$(
cat <<EOF
--------

[![GitHub License](https://img.shields.io/github/license/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME.svg)](https://raw.githubusercontent.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/master/LICENSE)

# Referral Links

This is an open source project, which means that we are giving our time to you for free. However like yourselves, we do have bills to pay. Please consider visiting some of these excellent services, they are not junk we can assure you, all services we would or do use ourselves.

[Really Excellent Dedicated Servers from Limestone Networks](http://www.limestonenetworks.com/?utm_campaign=rwreferrer&utm_medium=affiliate&utm_source=RFR16798) - fantastic service, great price.

[Low Cost and High Quality Cloud Hosting from Digital Ocean](https://www.digitalocean.com/?refcode=7b4639fc8194) - truly awesome service.

# Copyright and License

(c) 2015-2017 Neil Ellis all rights reserved. Please see [LICENSE](https://raw.githubusercontent.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/master/LICENSE) for license details of this project. Please visit http://neilellis.me for help and commercial support or raise issues on [GitHub](https://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/issues).

<div width="100%" align="right">
<img>
</div>

EOF
)

export HEADER=""
export TUTUM=""

git checkout -f master
git pull -f -n <<< "Rebasing master"
git config --global push.default simple
git branch --set-upstream-to=origin/${CI_BRANCH} ${CI_BRANCH}
git checkout ${CI_BRANCH}
git rebase master
git checkout master
git merge ${CI_BRANCH} -m "Merge from ${CI_BRANCH}"



git push --set-upstream origin master
if [[ -f README.md ]]
then
    envsubst '${RELEASE}:${BLURB}:${FOOTER}:${HEADER}:${STATE_SHELVED}:${STATE_EXPERIMENTAL}:${STATE_ACTIVE}:${STATE_PRE_ALPHA}:${STATE_ALPHA}:${STATE_BETA}:${STATE_PROD}:${TUTUM}' < README.tmpl.md > README.md
    git add README.md
fi
echo ${RELEASE} > .release
echo ${RELEASE} ${RELEASE_NUMBER} ${RELEASE_ID} ${CODENAME}  > .release.details
git commit -m "Release ${RELEASE}  [${RELEASE_NUMBER:-}/${RELEASE_ID:-}] (${CODENAME})" || :
git tag ${TAG} || :
git push --tags
git push origin master
