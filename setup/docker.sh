#!/bin/bash

COMPOSE_PROJECT_NAME=$(cat .env | grep COMPOSE_PROJECT_NAME | cut -d '=' -f2)
ELK_VERSION=$(cat .env | grep ELK_VERSION | cut -d '=' -f2)

tag_images(){
    docker images --filter=reference=''${COMPOSE_PROJECT_NAME}'*:latest' --format "{{.ID}} {{.Repository}}" | 
        while IFS= read -r line
        do
            docker tag $(echo $line | cut -d ' ' -f1) "$(echo ${line} | cut -d ' ' -f2):${ELK_VERSION}"
            docker image rm -f "$(echo ${line} | cut -d ' ' -f2):latest"
        done
}

delete_images(){
    docker image rm -f $(docker image ls --filter=reference=''${COMPOSE_PROJECT_NAME}'*' -q)
}

delete_volumes(){
    docker volume rm $(docker volume ls -f "name=${COMPOSE_PROJECT_NAME}_" -q)
}

# I know this is kind of ugly but it's not a priority
if [ "$EUID" -ne 0 ]; then echo "Please run as root."
    exit 1
elif [ $# -eq 0 ]; then
    echo "No arguments supplied, exiting..."
    exit 1
fi

if ! typeset -f $1 > /dev/null; then
    echo "Invalid argument."
fi

$1