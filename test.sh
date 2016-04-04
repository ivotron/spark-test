#!/bin/bash

docker=$1
shift
inst=$1
shift
cores=$1
shift
memgb=$1
shift
nverts=$*

if [ -z "$nverts" ]; then
  echo "USAGE: ./test.sh <docker img> <instances> <cores> <mem>g nvert[ nvert[ ...]]"
  exit 1
fi

echo "DOCKER IMG: $docker"
echo "INSTANCES: $inst"
echo "CORES/INST: $cores"
echo "GB/INST: ${memgb}g"
echo "NVERTS: $nverts"

for nvert in $nverts; do

  (docker run --rm --cidfile=/tmp/cid -e NVERTS=$nvert -e INSTANCES=$inst -e MEMGB=$memgb -e CORES=$cores $docker &)

  sleep 10
  cid=`cat /tmp/cid`
  pid=`docker inspect --format '{{ .State.Pid }}' $cid`

  if [ $? -ne 0 ]; then
    echo "ERROR: unable to get container's PID. Does it run OK?"
    exit 1
  fi

  while ps -p $pid > /dev/null ; do
    sleep 10
    if [ -f /cgroup/memory/docker/${cid}/memory.max_usage_in_bytes ] ; then
      max_mem=`cat /cgroup/memory/docker/${cid}/memory.max_usage_in_bytes`
      echo "max mem update: $max_mem"
    fi
  done

  echo "FINAL maxmem=$max_mem bytes / $(($max_mem / 1073741824)) gb" 
  rm /tmp/cid

done
