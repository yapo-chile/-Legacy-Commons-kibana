#!/usr/bin/env bash

#!/usr/bin/env bash
export UNAMESTR=$(uname)

# BRANCH info from travis
export BUILD_BRANCH=$(shell if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then echo "${TRAVIS_BRANCH}"; else echo "${TRAVIS_PULL_REQUEST_BRANCH}"; fi)

# GIT variables
export BRANCH=$(shell git branch | sed -n 's/^\* //p')
export GIT_BRANCH=$(shell if [ -n "${BUILD_BRANCH}" ]; then echo "${BUILD_BRANCH}"; else echo "${BRANCH}"; fi;)
export GIT_COMMIT=$(shell git rev-parse HEAD)
export GIT_COMMIT_DATE=$(shell TZ="America/Santiago" git show --quiet --date='format-local:%d-%m-%Y_%H:%M:%S' --format="%cd")
export BUILD_CREATOR=$(shell git log --format=format:%ae | head -n 1)

# REPORT_ARTIFACTS should be in sync with `RegexpFilePathMatcher` in
# `reports-publisher/config.json`
export REPORT_ARTIFACTS=reports

#APP variables
genport = $(shell expr \( $(shell id -u) - \( $(shell id -u) / 100 \) \* 100 \) \* 200 + 30200 + $(1))

export APPNAME=kibana
export VERSION=0.0.1
export EXEC=./${APPNAME}
export YO=$(shell expr `whoami`)
export LISTEN_PORT=9600
export SERVER_ROOT=${PWD}
export SERVERNAME=localhost
export BASE_URL="http://"${SERVERNAME}":"${LISTEN_PORT}
#DOCKER variables
export DOCKER_REGISTRY=containers.mpi-internal.com
export DOCKER_IMAGE=${DOCKER_REGISTRY}/yapo/${APPNAME}
export DOCKER_IMAGE_DEV=${DOCKER_REGISTRY}/yapo/${APPNAME}
export DOCKER_BINARY=${APPNAME}.docker
export DOCKER_PORT=9600

#LOGGER variables
export LOGGER_SYSLOG_ENABLED=false
export LOGGER_SYSLOG_IDENTITY=${APPNAME}
export LOGGER_STDLOG_ENABLED=true
export LOGGER_LOG_LEVEL=2

#RUNTIME variables
export RUNTIME_HOST=${SERVERNAME}
export RUNTIME_PORT=${LISTEN_PORT}


# REPORT_ARTIFACTS should be in sync with `RegexpFilePathMatcher` in
# `reports-publisher/config.json`
export REPORT_ARTIFACTS=reports

