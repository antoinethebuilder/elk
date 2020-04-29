#!/bin/bash

docker container stop $(docker container ls -qf "name=elastic") && \
echo "y" | docker container prune && echo "y" | docker volume prune && \
echo "y" | docker network prune
