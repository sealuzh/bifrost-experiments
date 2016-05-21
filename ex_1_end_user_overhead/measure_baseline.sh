#!/usr/bin/env bash
export COMPOSE_HTTP_TIMEOUT=600

source clean.sh
docker-compose -f docker-compose.yml up -d --force-recreate

for x in `seq 1 5`;
do

    docker-compose -f docker-compose.yml restart

	echo "clean db and seed"

	docker exec -ti bifrostmicroservicessampleapplication_auth_1 node seed.js
	docker exec -ti bifrostmicroservicessampleapplication_products_1 node seed.js

	echo "======================================================================="
	echo "| launching baseline run $x"
	echo "======================================================================="

    docker run --name bifrost-jmeter --net=bifrostmicroservicessampleapplication_default bifrostuzh/microservices-sample-jmeter bin/jmeter -n -t jmeter_20_threads_release.jmx
    docker cp bifrost-jmeter:/opt/jmeter/results.csv results.csv
    docker rm -f bifrost-jmeter

    mv results.csv baseline_${x}.csv

done

source clean.sh

