#!/usr/bin/env bash
export COMPOSE_HTTP_TIMEOUT=600

echo "======================================================================="
echo "| cleaning environment..."
echo "======================================================================="

docker-compose -f docker-compose.yml stop && docker-compose -f docker-compose.yml rm -f
docker-compose -f docker-compose-bifrost.yml stop && docker-compose -f docker-compose-bifrost.yml rm -f
docker rm -f bifrost-jmeter
docker rm -f cli