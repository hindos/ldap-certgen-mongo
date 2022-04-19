#!/bin/bash

cd docker

#docker-compose run -e SAN_DNS=$SAN_DNS \
#  cert-generator

docker-compose run cert-generator