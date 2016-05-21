#!/bin/sh

#
# Shell Script that allows to automatically provision a Docker Swarm in Google Cloud Engine
#
# - up <NODES> | Provision a node running consul for service-discovery and a number of #<NODES>, where the first node will be the swarm master.
# - down <NODES> | Pauses instances until you have a specific number of #<NODES> in your swarm.
#

set -e

create() {
  echo Setting up kv store
  docker-machine create \
    --driver google \
    --google-project $2 \
    bifrost-gce-swarm-kvstore && \
  docker-machine ssh bifrost-gce-swarm-kvstore $(ps axf | grep dnsmasq | grep -v grep | awk '{print "kill -9 " $1}') && \
  docker $(docker-machine config bifrost-gce-swarm-kvstore) run -d --restart=always --net=host progrium/consul --server -bootstrap-expect 1

  # get INTERNAL_IP of kvstore instance
  kvip=$(gcloud compute instances list bifrost-gce-swarm-kvstore | awk '{print $4}' | sed -n 2p)
  # kvip=10.128.0.2
  # kvip=$(docker-machine ip bifrost-gce-swarm-kvstore)

  echo "KV-Store has been created with IP ${kvip}"
  echo "Setting up Swarm-Master"

  docker-machine create \
    --engine-opt "cluster-store consul://${kvip}:8500" \
    --engine-opt "cluster-advertise eth0:2376" \
    --driver google \
    --google-project $2 \
    --swarm \
    --swarm-master \
    --swarm-discovery consul://${kvip}:8500 \
    bifrost-gce-swarm-node-1 &

  for ((i=2;i<=$1;i++)); do
    echo "Setting up Swarm-Node #${i}"
    docker-machine create \
      --engine-opt "cluster-store consul://${kvip}:8500" \
      --engine-opt "cluster-advertise eth0:2376" \
      --driver google \
      --google-project $2 \
      --swarm \
      --swarm-discovery consul://${kvip}:8500 \
      bifrost-gce-swarm-node-$i &
  done
  wait
}

teardown() {
  for ((i=$1+1;i>=2;i--)); do
    echo "Stopping Swarm-Node #${i}"
    docker-machine stop bifrost-gce-swarm-node-$i &
  done
  wait
}

case $1 in
  up)
    create $2 $3
    ;;
  down)
    teardown $2
    ;;
  *)
    echo "I literally can't even..."
    exit 1
    ;;
esac