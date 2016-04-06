#!/bin/bash
sudo swapoff
for x in 512 2048 16384 65536 262144 1048576 4194304 14000000 20000000; do
   sudo ./test.sh docker-spark-test 10 2 110 $x $x
done
