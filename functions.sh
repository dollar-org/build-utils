#!/usr/bin/env bash

export PATH=$PATH:/usr/local/Cellar/gettext/0.19.6/bin/
build_util_dir=${BUILD_UTILS_DIR:-../build-utils}

if [[ -n $CI ]]
then
    export CODENAME=$($build_util_dir/codenames/name.sh $CIRCLE_SHA1)
    export RELEASE=${RELEASE:-${CODENAME}-${CIRCLE_BUILD_NUM}}
else
    export RELEASE=local
    export CODENAME=local
fi


export TAG=${RELEASE}
export release=${RELEASE}
export AWS_DEFAULT_REGION=eu-west-1
export environment=${CIRCLE_BRANCH:-local}



changed() {
    if ${forced:-false}
    then
        true
    else
        if [[ -n $CI && -f ~/build-cache/last_sha ]]
        then
             (( $(git diff $(< ~/build-cache/last_sha) ${CIRCLE_SHA1} . | wc -l) > 0 ))
        else
            (( $(find . -type f -cmin -$age | wc -l) > 0 ))
        fi

    fi
}

undeployed() {
    if ${forced:-false}
    then
        true
    else
        if [[ -n $CI && -f ~/build-cache/last_deploy_sha ]]
        then
             (( $(git diff $(< ~/build-cache/last_deploy_sha) ${CIRCLE_SHA1} . | wc -l) > 0 ))
        else
            true
        fi

    fi
}



#See https://github.com/projectatomic/ContainerApplicationGenericLabels

dbuild() {
      if [[ $CI == "true" ]]
      then
         echo -n "LABEL vendor=\"Vizzbuzz (Cazcade Limited)\" " >> Dockerfile
         echo -n " build_date=\"$(date)\"" >> Dockerfile
         echo -n " release=\"${release}\"" >> Dockerfile
         echo -n " architecture=\"amd64\"" >> Dockerfile

         echo -n " vizzbuzz.build.sha1=\"${CIRCLE_SHA1:-}\"" >> Dockerfile
         echo -n " vizzbuzz.build.number=\"${CIRCLE_BUILD_NUM:-0}\"" >> Dockerfile
         echo -n " vizzbuzz.build.date.human=\"$(date)\"" >> Dockerfile
         echo  " vizzbuzz.build.date.millis=\"$(date +%s)000\"" >> Dockerfile
         docker build ${cache_flags:-} -t $1 .
      else
         docker build ${cache_flags:-} -t $1 .
      fi
}

copy() {
 rsync -av $@
}

ifnewer() {
    if [[ $1 -nt $2 ]]
    then
        eval $3
    fi

}

update_config() {
    ifnewer public/template_config.js public/vb_config.js "envsubst < public/template_config.js > public/vb_config.js"
}


#if [[ $ttag == "master" ]]
#then
#    version="${CIRCLE_BUILD_NUM:-dev}"
#else
#    version=$ttag
#fi

dpush() {
    if docker images | grep "^${1} "
    then
        docker tag -f $1 tutum.co/neilellis/$1:${release}
        docker push tutum.co/neilellis/$1:${release}
    fi
}

dflatten() {
    cont=$(docker run -d $1)
    sleep 5
    docker logs $cont
    docker export $cont | docker import - $1
    docker kill $cont
}

s3_deploy() {

    if [[ $environment == master ]]
    then
        export DEPLOY_PREFIX=${CODENAME}
        envsubst < ${build_util_dir}/redirect.html > out/redirect-expanded.html
        cp -f  ${build_util_dir}/s3_website.yml .
        s3_website cfg apply --headless
        s3_website push
        #   Wait for everything to be ready
        sleep 60
        aws s3 sync --delete --cache-control "max-age=0, no-cache, no-store, private" --expires ""   --exclude "*assets/scss/*" --exclude "*typings/*"   out/ s3://${DEPLOY_HOST}/current/
        aws s3 cp --quiet --cache-control "max-age=10" out/redirect-expanded.html s3://${DEPLOY_HOST}/index.html
    else
        export DEPLOY_PREFIX=nocache/${environment}/$(date +%s)
        envsubst < ${build_util_dir}/redirect.html > out/redirect-expanded.html
        aws s3 cp --cache-control "max-age=10" out/redirect-expanded.html s3://${DEPLOY_HOST}/nocache/${environment}/index.html
        aws s3 sync  --delete --cache-control "max-age=0, no-cache, no-store, private" --expires ""  --exclude "*assets/scss/*" --exclude "*typings/*"   out/ s3://${DEPLOY_HOST}/${DEPLOY_PREFIX}/
        aws s3 sync  --delete --cache-control "max-age=0, no-cache, no-store, private" --expires ""  --exclude "*assets/scss/*" --exclude "*typings/*"   out/ s3://${DEPLOY_HOST}/${environment}/
    fi

}


#if [[ -n ${DOCKER_USER} ]] && which docker
#then
#  docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS tutum.co
#fi
#
#if [[ -n ${TUTUM_USERNAME} ]] && which tutum
#then
#    echo "Logging in to Tutum"
#    tutum login -u $TUTUM_USERNAME -p $TUTUM_PASSWORD
#fi



#function routes3() {
#    aws s3 sync --quiet --delete --cache-control "no-cache" s3://$1/${3}/ s3://$1/previous/
#    echo ${4} > /tmp/version
#    echo ${4},${codename:-},${CIRCLE_BUILD_NUM},${CIRCLE_SHA1},${CIRCLE_COMPARE_URL},$(date) > /tmp/build
#    aws s3 cp  /tmp/version s3://$1/${4}/.version
#    aws s3 cp /tmp/build s3://$1/${4}/.build
#    aws s3 cp /tmp/version s3://$1/${3}/.stale
#
#    if [[ $2 == "forward" ]]
#    then
#        live=${4}
#    else
#        live=${3}
#    fi
#    aws s3 sync --quiet --delete --cache-control "no-cache" s3://$1/${live}/ s3://$1/current/
#
#    ws_config=$(
#    cat << EOF
#    {
#        "ErrorDocument": {
#            "Key": "error.html"
#        },
#        "IndexDocument": {
#            "Suffix": "index.html"
#        },
#        "RoutingRules": [
#            {
#                "Condition": {
#                    "KeyPrefixEquals": "live/"
#                },
#                "Redirect": {
#                    "HostName": "$1",
#                "HttpRedirectCode": "302",
#                "Protocol": "https",
#                "ReplaceKeyPrefixWith": "$live/"
#            }
#        }
#    ]
#}
#
#EOF
#)
#
#    aws s3api put-bucket-website --bucket $1 --website-configuration "$ws_config"
#
#}
#
