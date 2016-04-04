#!/bin/bash
set -x
set -e

sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
service ssh start

ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

pushd spark-1.6.1-bin-hadoop2.6

echo localhost > conf/slaves
echo SPARK_WORKER_INSTANCES=3 > conf/spark-env.sh
echo SPARK_WORKER_CORES=1 >> conf/spark-env.sh
echo SPARK_WORKER_MEMORY=2g >> conf/spark-env.sh

sbin/start-all.sh

MASTER="spark://`hostname`:7077" bin/run-example graphx.SynthBenchmark -app=pagerank -niters=10 -seed=1234 -nverts=100
