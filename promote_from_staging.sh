#!/bin/bash -ex

cd $(dirname $0)
DIR=$(pwd)
cd -

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

[![GitHub Issues](https://img.shields.io/github/issues/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.svg)](https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues)

[![Join the chat at https://gitter.im/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

-------

EOF
)

export FOOTER=$(
cat <<EOF
--------

[![GitHub License](https://img.shields.io/github/license/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME.svg)](https://raw.githubusercontent.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/master/LICENSE)

#Referral Links

This is an open source project, which means that we are giving our time to you for free. However like yourselves, we do have bills to pay. Please consider visiting some of these excellent services, they are not junk we can assure you, all services we would or do use ourselves.

[Really Excellent Dedicated Servers from Limestone Networks](http://www.limestonenetworks.com/?utm_campaign=rwreferrer&utm_medium=affiliate&utm_source=RFR16798) - fantastic service, great price.

[Low Cost and High Quality Cloud Hosting from Digital Ocean](https://www.digitalocean.com/?refcode=7b4639fc8194) - truly awesome service.

[Excellent Single Page Website Creation and Hosting from Strikingly](http://strk.ly/?uc=kDaE2vgzc3F) - http://sillelien.com uses this.

(c) 2015 Sillelien all rights reserved. Please see [LICENSE](https://raw.githubusercontent.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/master/LICENSE) for license details of this project. Please visit http://sillelien.com for help and commercial support or raise issues on [GitHub](https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/issues).


<div width="100%" align="right">
<img src='https://da8lb468m8h1w.cloudfront.net/v2/cpanel/8398500-121258714_3-s1-v1.png?palette=1' >
</div>

EOF
)

export HEADER=""

export TUTUM="[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)"
export CODENAME=$($DIR/codenames/name.sh $CIRCLE_SHA1)

git checkout master
git pull 
git merge staging -m "Auto merge"
echo ${RELEASE} > .release
echo ${RELEASE} ${CODENAME} ${CIRCLE_SHA1} > .release.details
envsubst '${RELEASE}:${BLURB}:${FOOTER}:${HEADER}:${STATE_SHELVED}:${STATE_EXPERIMENTAL}:${STATE_ACTIVE}:${STATE_PRE_ALPHA}:${STATE_ALPHA}:${STATE_BETA}:${STATE_PROD}:${TUTUM}' < README.tmpl.md > README.md
git add README.md .release .release.details
git commit -a -m "Promotion from staging of ${RELEASE}" || :
git push
git tag ${RELEASE} || :
git push --tags
git push origin master
