.DEFAULT_GOAL:=help

# This for future release of Compose that will use Docker Buildkit, which is much efficient.
COMPOSE_PREFIX_CMD := COMPOSE_DOCKER_CLI_BUILD=1

COMPOSE_ALL_FILES := -f docker-compose.yml 
ELK_SERVICES := elasticsearch logstash kibana
ELK_MAIN_SERVICES := ${ELK_SERVICES}
# --------------------------

.PHONY: setup populate certs all build stop restart rm logs
certs:		    ## Generate SSL certificates for all instances.
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.setup.yml run --rm certs
setup:			## Setup Elasticsearch's keystore.
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.setup.yml run --rm elastic_keystore
	@make certs
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.yml up -d --build elasticsearch
	@./setup/gen-password.sh
populate:		## Populates the keystore of the Kibana and Logstash instance.
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.setup.yml run --rm kibana_keystore
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.setup.yml run --rm logstash_keystore
run:            ## Run Kibana and Logstash with SSL.
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.yml up -d --build kibana
	@${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.yml up -d --build logstash
build:			## Build ELK and all its extra components.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} build ${ELK_SERVICES}
stack:			## Setup, populate, deploy ELK. [recommended]
	@make setup
	@make populate
	@make run
stop:			## Stop ELK.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} stop ${ELK_SERVICES}
restart:		## Restart ELK.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} restart ${ELK_SERVICES}
rm:				## Remove ELK. (Containers only)
	@${COMPOSE_PREFIX_CMD} docker-compose $(COMPOSE_ALL_FILES) rm -f ${ELK_SERVICES}
purge:			## Deletes ALL stopped containers and ALL unused volumes.
	@make stop && make rm && docker volume prune -f
help:       	## Show this help.
	@echo "Deploy/Build an Elasticstack with SSL"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
