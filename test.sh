#!/bin/bash

docker=$1
shift
spark_env_sh_file=$1
shift
spark_defaults_conf_file=$1
shift
nverts=$*

if [ -z "$nverts" ]; then
  echo "USAGE: ./test.sh <docker img> <spark_env_sh_file> <spark_defaults_conf_file> nvert[ nvert[ ...]]"
  exit 1
fi

echo "DOCKER IMG: $docker"
echo "spark_env_sh_file: $spark_env_sh_file"
echo "spark_defaults_conf_file: $spark_defaults_conf_file"
echo "NVERTS: $nverts"

if [ -f "$spark_env_sh_file" ]; then
  echo "spark_env_sh_file exists: $spark_env_sh_file"
else
  echo "spark_env_sh_file does NOT exist: $spark_env_sh_file"
  echo "exiting now"
  exit 1
fi

if [ -f "$spark_defaults_conf_file" ]; then
  echo "spark_defaults_conf_file exists: $sspark_defaults_conf_file"
else
  echo "spark_defaults_conf_file does NOT exist: $spark_defaults_conf_file"
  echo "exiting now"
  exit 1
fi

for nvert in $nverts; do

  (docker run --rm --cidfile=/tmp/cid -e NVERTS=$nvert -v $spark_env_sh_file:/spark-1.6.1-bin-hadoop2.6/conf/spark-env.sh -v $spark_defaults_conf_file:/spark-1.6.1-bin-hadoop2.6/conf/spark-defaults.conf $docker &)

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
