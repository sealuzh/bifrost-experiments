#!/usr/bin/env bash

echo "======================================================================="
echo "| starting parallel release performance test"
echo "======================================================================="

source setup.sh
docker-compose restart bifrost

echo "======================================================================="
echo "| creating proxy"
echo "======================================================================="

docker rm -f products_proxy_1
docker run -d --name products_proxy_1 --net=parallelreleaseperformance_default -e NODE_ENV=production -e PROXIED_HOST=products -e PROXIED_PORT=80 -e constraint:node!=bifrost-gce-swarm-node-2 -e constraint:node!=bifrost-gce-swarm-node-3 -e constraint:node!=bifrost-gce-swarm-node-11 bifrostuzh/proxy

echo "======================================================================="
echo "| creating releases"
echo "======================================================================="

for x in $(seq 1 $1);
do 
  docker rm -f cli_${x}
  docker create -t --name cli_${x} --net=parallelreleaseperformance_default -e constraint:node!=bifrost-gce-swarm-node-2 -e constraint:node!=bifrost-gce-swarm-node-11 -e constraint:node!=bifrost-gce-swarm-node-3 bifrostuzh/microservices-sample-cli sh -c "node bifrost-run.js --engine bifrost:8181 parallel_release_strategy.yml"
done

echo "======================================================================="
echo "| starting releases"
echo "======================================================================="

# run
for x in $(seq 1 $1);
do
   { time docker start -a cli_${x} > bifrost_log_$1.txt ; } 2>> bifrost_release_time_$1.txt &
done

# pull stats from specific node that runs the bifrost engine
docker-machine ssh bifrost-gce-swarm-node-2 "sudo curl --max-time 320 --unix-socket /var/run/docker.sock http:/containers/bifrost/stats" >> bifrost_stats_$1.txt

# remove all started containers
docker ps -a | awk '{ print $1,$2 }' | grep bifrostuzh/microservices-sample-cli | awk '{print $1 }' | xargs -I {} docker rm -f {}
docker ps -a | awk '{ print $1,$2 }' | grep bifrostuzh/proxy | awk '{print $1 }' | xargs -I {} docker rm -f {}