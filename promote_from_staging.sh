#!/bin/bash -ex
if [[ -n $CI_LOCAL ]]
then
    exit 0
fi

cd $(dirname $0)
DIR=$(pwd)
cd -

. $DIR/functions.sh

[[ -f env.sh ]] && . env.sh

export CI_BRANCH=${CI_BRANCH:-${CIRCLE_BRANCH}}
export CI_BUILD_NUM=${CI_BUILD_NUM:-${CIRCLE_BUILD_NUM}}
export CI_PROJECT_USERNAME=${CI_PROJECT_USERNAME:-${CIRCLE_PROJECT_USERNAME}}
export CI_PROJECT_REPONAME=${CI_PROJECT_REPONAME:-${CIRCLE_PROJECT_REPONAME}}

if [[ ${CI_BRANCH} == "staging" ]]
then
    export RELEASE=${RELEASE:-${CI_BUILD_NUM}}
    export TAG=${RELEASE_NUMBER:-${CI_BUILD_NUM}}
else
    export RELEASE=${RELEASE:-${CI_BRANCH}}
    export TAG=${RELEASE_NUMBER:-${CI_BUILD_NUM}}
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

** If you use this project please consider giving us a star on [GitHub](http://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME). **

Please contact me through Gitter (chat) or through GitHub Issues.

[![GitHub Issues](https://img.shields.io/github/issues/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME.svg)](https://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/issues) [![Join the chat at https://gitter.im/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

For commercial support please <a href="mailto:hello@neilellis.me">contact me directly</a>.
-------

EOF
)

export FOOTER=$(
cat <<EOF
--------

# Referral Links

This is an open source project, which means that we are giving our time to you for free. However like yourselves, we do have bills to pay. Please consider visiting some of these excellent services, they are not junk we can assure you, all services we would or do use ourselves.

[Really Excellent Dedicated Servers from Limestone Networks](http://www.limestonenetworks.com/?utm_campaign=rwreferrer&utm_medium=affiliate&utm_source=RFR16798) - fantastic service, great price.

[Low Cost and High Quality Cloud Hosting from Digital Ocean](https://www.digitalocean.com/?refcode=7b4639fc8194) - truly awesome service.

# Copyright and License

[![GitHub License](https://img.shields.io/github/license/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME.svg)](https://raw.githubusercontent.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/master/LICENSE)

(c) 2014-2017 Neil Ellis all rights reserved. Please see [LICENSE](https://raw.githubusercontent.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/master/LICENSE) for license details of this project. Please visit http://neilellis.me for help and raise issues on [GitHub](https://github.com/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME/issues).

For commercial support please <a href="mailto:hello@neilellis.me">contact me directly</a>.

<div width="100%" align="right">
<img>
</div>

EOF
)

export HEADER=$(
cat <<EOF
Build: [![Circle CI](https://circleci.com/gh/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME.png?style=badge)](https://circleci.com/gh/$CI_PROJECT_USERNAME/$CI_PROJECT_REPONAME)

[ ![Download](https://api.bintray.com/packages/$CI_PROJECT_USERNAME/maven/$CI_PROJECT_REPONAME/images/download.svg) ](https://bintray.com/$CI_PROJECT_USERNAME/maven/$CI_PROJECT_REPONAME/_latestVersion)

EOF
)

export DOWNLOAD=$(
cat <<EOF
[ ![Download](https://api.bintray.com/packages/$CI_PROJECT_USERNAME/maven/$CI_PROJECT_REPONAME/images/download.svg) ](https://bintray.com/$CI_PROJECT_USERNAME/maven/$CI_PROJECT_REPONAME/_latestVersion)

EOF
)

export TUTUM=""

git checkout -f master
git pull -f -n <<< "Rebasing master"
git config --global push.default simple
git branch --set-upstream-to=origin/${CI_BRANCH} ${CI_BRANCH}
git checkout ${CI_BRANCH}
git rebase master
git checkout master
git merge ${CI_BRANCH} -m "Merge from ${CI_BRANCH} for ${RELEASE}"
#git push --set-upstream origin master
if [[ -f README.tmpl.md  ]]
then
    envsubst '${RELEASE}:${BLURB}:${FOOTER}:${HEADER}:${STATE_SHELVED}:${STATE_EXPERIMENTAL}:${STATE_ACTIVE}:${STATE_PRE_ALPHA}:${STATE_ALPHA}:${STATE_BETA}:${STATE_PROD}:${DOWNLOAD}' < README.tmpl.md > README.staged.md
    git add README.staged.md
fi
echo ${RELEASE} > .release
git add .release
echo ${RELEASE} ${RELEASE_NUMBER} ${RELEASE_ID} ${CODENAME}  > .release.details
git add .release.details
github_changelog_generator --token=${GITHUB_TOKEN}
git add CHANGELOG.md
git commit -m "Release ${RELEASE} (${CODENAME})" || :
git tag ${TAG} || :
git push --tags
git push origin master
