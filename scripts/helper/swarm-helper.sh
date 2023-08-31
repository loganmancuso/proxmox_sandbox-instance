#!/bin/bash

#####################################################################################
## docker-status.sh - Bash script that checks status for docker swarm services and nodes.
## Functions: 
# check_replication - Check if all stacks are running in service.
# check_swarm_nodes - Check if all nodes are reacheble and healthy. 
# check_swarm_services - Check if any of the services failed. 
#####################################################################################

# set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

set -o pipefail

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

warning=0
critical=0
unknown=0
state_replicated=0
state_swarm=0

if [ "$(whoami)" != "root" ]; then
  echo "Root privileges are required to run this, try running with sudo..."
  exit $STATE_CRITICAL
fi

if [ "x$(which docker)" == "x" ]; then
  echo "UNKNOWN - Missing docker binary"
  exit $STATE_UNKNOWN
fi

systemctl status docker > /dev/null 2>&1
if [ "${?}" != 0 ]; then 
  echo "Docker daemon is not running"
  exit ${STATE_CRITICAL} 
fi

which json_reformat > /dev/null 2>&1
if [ "${?}" -ne 0 ]; then
  echo "json_reformat is not installed"
  exit ${STATE_CRITICAL} 
fi

usage() {
  echo "Usage: 
  $0 swarm_check
  $0 check_replication
  $0 check_swarm_services
  $0 balance_swarm_services"
  return $STATE_WARNING
}

function isManager(){
  isManaget=`docker info | grep 'Is Manager'| awk -F' ' '{print $3}'`
  if [ "${isManaget}" == "false" ]; then
    echo "OK - Not a swarm master"
    exit 0
  fi
}

function check_swarm_nodes(){
  isManager
  for NODE in `docker node ls | egrep 'Leader|Reachable|Reachable'| awk '{print $1}'`;do
    ManagerStatus=$(docker node inspect --format="{{.ManagerStatus.Reachability}}" $NODE) > /dev/null 2>&1
    if  [ "$ManagerStatus" == "Unavailable" ]; then
      let "state_swarm=state_swarm+1"
    fi
  done

  if [ "$state_swarm" -gt 0 ]; then
    echo "CRITICAL - Not all swarm nodes are healthy"
  else
    echo "OK - All swarm nodes are healthy" 
  fi 
  return $state_swarm
}

function check_replication(){
  isManager
  for i in `docker service ls -q`; do
    replicated=`docker service inspect --pretty $i | grep -i "Service Mode" | awk '{print $3}'`
    if [ "${replicated}" == "Replicated" ]; then
      replicas=`docker service inspect --pretty $i | grep -i replicas | awk '{print $2}'`
      running_replicas=`docker service ps $i |grep -i running | wc -l`
      if [ ${replicas} -ne "${running_replicas}" ]; then
        let "state_replicated=state_replicated+1"
      fi
    fi
  done 

  if [ "$state_replicated" -gt 0 ]; then
    echo "CRITICAL - Not all services are replicated"
  else
    echo "OK - All services are replicated" 
  fi 
  return $state_replicated
}

function check_swarm_services(){  
  isManager
  for i in `docker service ls -q`; do
    docker service ps $i | grep -E "Failed [0-9]* second" > /dev/null 2&1
    if [ "${?}" -ne 0 ]; then
      echo "CRITICAL - Some services failed to start"
    fi
  done 
}

function balance_swarm_services(){  
  set -e
  until check_swarm_nodes;  do 
    echo waiting for swarm nodes to come back online
    sleep 10
  done
  EXCLUDE_LIST="(_db|portainer|broker|prune|logspout|NAME)"
  for service in $(docker service ls | egrep -v $EXCLUDE_LIST | awk '{print $2}'); do
    docker service update --force $service
  done
}

### Main
case $1 in
  check_replication)
    check_replication
    ;;
  swarm_check)
    check_swarm_nodes
    ;;
  swarm_service_check)
    check_swarm_services
    ;;
  balance_swarm_services)
    balance_swarm_services
    ;;
  *)
    usage
    exit $?
esac
### END