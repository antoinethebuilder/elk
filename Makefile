.DEFAULT_GOAL:=help

# This for future release of Compose that will use Docker Buildkit, which is much efficient.
BUILDKIT := COMPOSE_DOCKER_CLI_BUILD=1 # Optional
COMPOSE_ALL_FILES :=  docker-compose.yml
COMPOSE_SETUP_FILE := docker-compose.setup.yml
COMPOSE_BUILD_FILE := docker-compose.build.yml
COMPOSE_PROJECT_NAME="$(cat .env | grep COMPOSE_PROJECT_NAME | cut -d '=' -f2)"

ELK_SERVICES := elasticsearch logstash kibana
# --------------------------

.PHONY: deploy logs start stop restart down nuke help
deploy:	build-all bootstrap kibana-keystore	start-kibana    			## Deploy everything from scratch [recommended]
logs: 																	## Logs of the ELK
	@docker-compose -f ${COMPOSE_ALL_FILES} logs -f elasticsearch kibana
start: start-elasticsearch start-kibana         						## Start ELK

stop:																	## Stop ELK
	docker-compose -f ${COMPOSE_ALL_FILES} stop ${ELK_SERVICES}
restart: stop start														## Restart ELK.

down:																	## Remove ELK. (Containers only)
	@docker-compose -f $(COMPOSE_ALL_FILES) down && ./setup/docker.sh delete_volumes
nuke:																	## Deletes ALL stopped containers, unused volumes and unused networks
	@docker container prune -f && docker network prune -f && docker container volumes prune -f
help:       															## Show this help
	@echo "Deploy/Build an Elasticstack with SSL"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
# --------------------------

# BOOTSTRAP
.PHONY: bootstrap 
bootstrap: gen-certificates 
	@echo "+ $@"
	@docker-compose -f docker-compose.yml up -d elasticsearch
	@./setup/gen-password.sh

# BUILDS
.PHONY: build-all
build-all: build-elastic build-kibana tag-images
	@echo "Successfully built the following services:"
	@docker images --filter=reference='${COMPOSE_PROJECT_NAME}*' --format "{{.ID}} {{.Repository}}"

.PHONY: build-elastic
build-elastic:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_BUILD_FILE} build -q elasticsearch

.PHONY: build-kibana
build-kibana:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_BUILD_FILE} build -q kibana

.PHONY: build-logstash
build-logstash:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_BUILD_FILE} build -q logstash

# HTTPS/TLS + KEYSTORE
.PHONY: elastic-keystore
elastic-keystore:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_SETUP_FILE} run --rm elastic_keystore

.PHONY: kibana-keystore
kibana-keystore:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_SETUP_FILE} run --rm kibana_keystore

.PHONY: gen-certificates
gen-certificates:
	@echo "+ $@"
	@docker-compose -f ${COMPOSE_SETUP_FILE} run --rm certs

# CONTAINER MANAGEMENT
.PHONY: start-kibana
start-kibana:
	@docker-compose -f ${COMPOSE_ALL_FILES} up -d kibana

.PHONY: stop-kibana
stop-kibana:
	@docker-compose -f ${COMPOSE_ALL_FILES} stop kibana

.PHONY: logs-kibana
logs-kibana:
	@docker-compose -f ${COMPOSE_ALL_FILES} logs -f kibana

.PHONY: start-elasticsearch
start-elasticsearch:
	@docker-compose -f ${COMPOSE_ALL_FILES} up -d elasticsearch

.PHONY: stop-elasticsearch
stop-elasticsearch:
	@docker-compose -f ${COMPOSE_ALL_FILES} stop elasticsearch

.PHONY: logs-elasticsearch
logs-elasticsearch:
	@docker-compose -f ${COMPOSE_ALL_FILES} logs -f elasticsearch
.PHONY: start-logstash
start-logstash:
	@docker-compose -f ${COMPOSE_ALL_FILES} up -d logstash

.PHONY: stop-logstash
stop-logstash:
	@docker-compose -f ${COMPOSE_ALL_FILES} stop logstash

.PHONY: logs-logstash
logs-logstash:
	@docker-compose -f ${COMPOSE_ALL_FILES} logs -f logstash

# IMAGE MANIPULATION
.PHONY: tag-images
tag-images:
	@echo "+ $@"
	@./setup/docker.sh tag_images

.PHONY: delete-images
delete-images:
	@echo "- $@"
	@./setup/docker.sh delete_images
