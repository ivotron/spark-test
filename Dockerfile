FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install default-jdk vim tmux git curl

RUN curl -O http://apache.cs.utah.edu/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz
RUN tar xzf spark-1.6.1-bin-hadoop2.6.tgz

RUN apt-get -y install openssh-server

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 4040 4041
