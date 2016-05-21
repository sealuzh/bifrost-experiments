#!/usr/bin/env bash
export COMPOSE_HTTP_TIMEOUT=600

sleep 30
docker run -t --name cli --net=bifrostmicroservicessampleapplication_default -e affinity:image==bifrostuzh/microservices-sample-cli bifrostuzh/microservices-sample-cli node bifrost-run.js --engine bifrost:8181 bifrost.yml > bifrost_log_$1.txt
docker rm -f cli