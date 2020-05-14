#!/usr/bin/env bash

# Include colors.sh
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/colors.sh"

#Build code again now for docker platform
echoHeader "Building code for docker platform"
set -e
rm -f ${DOCKER_BINARY}
#GOOS=linux GOARCH=386 go build -v -o ${DOCKER_BINARY} ./${MAIN_FILE}

set +e

if ! [[ -n "$TRAVIS" ]]; then
   echoTitle "Starting Docker Engine"
   if [[ $OSTYPE == "darwin"* ]]; then
       echoTitle "Starting Mac OSX Docker Daemon"
       $DIR/docker-start-macosx.sh
   elif [[ "$OSTYPE" == "linux-gnu" ]]; then
       echoTitle "Starting Linux Docker Daemon"
       sudo start-docker-daemon
   else
       echoError "Platform not supported"
   fi
fi

########### DYNAMIC VARS ###############

#In case we are in travis, docker tag will be "branch_name-20180101-1200". In case of master branch, branch-name is blank.
#In case of local build (not in travis) tag will be "local".
if [[ -n "$TRAVIS" ]]; then
    if [ "${GIT_BRANCH}" != "master" ]; then
        DOCKER_TAG=$(echo ${GIT_BRANCH} | tr '[:upper:]' '[:lower:]' | sed 's,/,_,g')
    else
        DOCKER_TAG=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d_%H%M%S' --format="%cd")
    fi
else
    DOCKER_TAG=local
fi

echo "Building docker image for ${DOCKER_IMAGE}"
echo "GIT BRANCH: ${GIT_BRANCH}"
echo "GIT TAG: ${GIT_TAG}"
echo "GIT COMMIT: ${GIT_COMMIT}"
echo "GIT COMMIT SHORT: ${GIT_COMMIT_SHORT}"
echo "BUILD CREATOR: ${BUILD_CREATOR}"

export GIT_BRANCH_LOWERCASE=$(echo "${GIT_BRANCH}" | awk '{print tolower($0)}'| sed 's/\//_/;')
DOCKER_ARGS=" --no-cache"

if [[ "$GIT_TAG" != "" ]]; then
     DOCKER_ARGS="${DOCKER_ARGS} \
         -t ${DOCKER_IMAGE}:${GIT_TAG}"
elif [[ "${GIT_BRANCH_LOWERCASE}" == "master" ]]; then
     DOCKER_ARGS="${DOCKER_ARGS} \
         -t ${DOCKER_IMAGE}:${GIT_BRANCH_LOWERCASE} -t ${DOCKER_IMAGE}:latest"
else
     DOCKER_ARGS="${DOCKER_ARGS} \
         -t ${DOCKER_IMAGE}:${GIT_BRANCH_LOWERCASE}"
fi

DOCKER_ARGS=" \
    -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
    --build-arg GIT_BRANCH="$GIT_BRANCH" \
    --build-arg GIT_COMMIT="$GIT_COMMIT" \
    --build-arg GIT_COMMIT_DATE="$GIT_COMMIT_DATE" \
    --build-arg BUILD_CREATOR="$BUILD_CREATOR" \
    --build-arg APPNAME="$APPNAME" \
    -f docker/dockerfile \
    ."
    
echo "args: ${DOCKER_ARGS}"
set -x
docker build ${DOCKER_ARGS}
set +x

echoTitle "Build done"