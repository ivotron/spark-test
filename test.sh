#!/bin/bash

(docker run --rm --cidfile=/tmp/cid -e NVERTS=1000000 -e INSTANCES=3 -e MEMGB=10 -e CORES=1 docker-test &)

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
