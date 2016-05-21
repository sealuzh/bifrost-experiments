#!/usr/bin/env bash

echo "======================================================================="
echo "| starting complex release performance test"
echo "======================================================================="

rm bifrost_stats_$1.txt
rm bifrost_log_$1.txt
rm bifrost_release_time_$1.txt

docker-compose restart bifrost

sleep 5

# Start 10 new proxies, for 10 more releases
echo "======================================================================="
echo "| start proxies"
echo "======================================================================="

docker run -d --name products_proxy_1 --net=complexproxyperformance_default -e NODE_ENV=production -e PROXIED_HOST=products -e PROXIED_PORT=80 -e constraint:node!=bifrost-gce-swarm-node-4 bifrostuzh/proxy

sleep 10

#collectStats &

echo "======================================================================="
echo "| start releases"
echo "======================================================================="

# run
{ time docker run -t --net=complexproxyperformance_default -e constraint:node!=bifrost-gce-swarm-node-4 bifrostuzh/microservices-sample-cli node bifrost-run.js --engine bifrost:8181 experiment3_step_$1.yml >> bifrost_log_$1.txt ; } 2>> bifrost_release_time_$1.txt &

docker-machine ssh bifrost-gce-swarm-node-4 "sudo curl --max-time 180 --unix-socket /var/run/docker.sock http:/containers/bifrost/stats" >> bifrost_stats_$1.txt

docker ps -a | awk '{ print $1,$2 }' | grep bifrostuzh/microservices-sample-cli | awk '{print $1 }' | xargs -I {} docker rm -f {}
docker ps -a | awk '{ print $1,$2 }' | grep bifrostuzh/proxy | awk '{print $1 }' | xargs -I {} docker rm -f {}