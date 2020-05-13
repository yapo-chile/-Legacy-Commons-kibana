include scripts/commands/vars.mk
export BRANCH ?= $(shell git branch | sed -n 's/^\* //p')
export COMMIT_DATE_UTC ?= $(shell TZ=UTC git show --quiet --date='format-local:%Y%m%d_%H%M%S' --format="%cd")

export DOCKER_TAG ?= $(shell echo ${BRANCH} | tr '[:upper:]' '[:lower:]' | sed 's,/,_,g')
export CHART_DIR ?= k8s/${APPNAME}

info:
	@echo "YO           : "${YO}
	@echo "ServerRoot   : "${SERVER_ROOT}
	@echo "API Base URL : "${BASE_URL}
	@echo "DB Base URL : "${DATABASE_BASE_URL}

helm-publish:
	@echo "Publishing helm package to Artifactory"
	helm lint ${CHART_DIR}
	helm package ${CHART_DIR}
	jfrog rt u "*.tgz" "helm-local/yapo/" || true

build:
	@scripts/commands/build.local.sh

# Starts a redis server
redis-start:
	@redis-server --port ${REDIS_PORT} --daemonize yes --databases 5

redis-stop:
	@redis-cli shutdown

# Starts a db server
db-start:
	@scripts/pgsql_ctl.sh start ${DATABASE_PORT} ${DATABASE_NAME}

db-stop:
	@scripts/pgsql_ctl.sh stop ${DATABASE_PORT} ${DATABASE_NAME}

run:
	${EXEC}

start: build db-start run

docker-build:
	@scripts/commands/build.docker.sh

docker-build-dev:
	@scripts/commands/build.docker.dev.sh

docker-publish:
	@scripts/commands/docker-publish.sh

docker-redis:
	docker run -d -p ${REDIS_PORT}:${REDIS_PORT} redis

docker-run:
	docker run -v ${PWD}/pipeline:/usr/share/kibana/pipeline --env-file scripts/commands/docker-vars.mk -p ${LISTEN_PORT}:${DOCKER_PORT} ${DOCKER_IMAGE}:local 

daemonize:
	@nohup sudo ${EXEC} >> logs/${EXEC}.log 2>&1 &

validate:
	scripts/commands/validate.sh

fix-format:
	scripts/commands/fix-format.sh

tests:
	scripts/commands/tests.sh

setup:
	scripts/commands/dependencies.sh
