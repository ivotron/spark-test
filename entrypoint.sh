#!/bin/bash
set -x
set -e

nverts=${NVERTS:-100}
instances=${INSTANCES:-3}
memgb=${MEMGB:-2}
cores=${CORES:-1}

sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
service ssh start

ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

pushd spark-1.6.1-bin-hadoop2.6

echo localhost > conf/slaves
echo SPARK_WORKER_INSTANCES=$instances > conf/spark-env.sh
echo SPARK_WORKER_CORES=$cores >> conf/spark-env.sh
echo SPARK_EXECUTOR_INSTANCES=$instances >> conf/spark-defaults.conf

#echo SPARK_WORKER_MEMORY=${memgb}g >> conf/spark-env.sh
echo "spark.executor.memory ${memgb}g" >> conf/spark-defaults.conf
echo "spark.executor.extraJavaOptions -d64 -server -XX:GCTimeRatio=24 -XX:InitiatingHeapOccupancyPercent=80 -XX:+UseG1GC" >> conf/spark-defaults.conf

sbin/start-all.sh

MASTER="spark://`hostname`:7077" bin/run-example graphx.SynthBenchmark \
  -app=pagerank -niters=10 -seed=1234 -nverts=$nverts
