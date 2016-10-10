FROM ubuntu:16.04

MAINTAINER Abdul Rehman <abdul@huddlebuy.com>

RUN apt-get update -y
RUN apt-get install php7.0 -y
RUN export DEBIAN_FRONTEND=noninteractive
RUN sudo -E apt-get -q -y install mysql-server
RUN unset DEBIAN_FRONTEND

CMD cd /web && php -S 0.0.0.0:8020
